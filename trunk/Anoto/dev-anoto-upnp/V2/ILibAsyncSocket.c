/*
 * INTEL CONFIDENTIAL
 * Copyright (c) 2002, 2003 Intel Corporation.  All rights reserved.
 * 
 * The source code contained or described herein and all documents
 * related to the source code ("Material") are owned by Intel
 * Corporation or its suppliers or licensors.  Title to the
 * Material remains with Intel Corporation or its suppliers and
 * licensors.  The Material contains trade secrets and proprietary
 * and confidential information of Intel or its suppliers and
 * licensors. The Material is protected by worldwide copyright and
 * trade secret laws and treaty provisions.  No part of the Material
 * may be used, copied, reproduced, modified, published, uploaded,
 * posted, transmitted, distributed, or disclosed in any way without
 * Intel's prior express written permission.
 
 * No license under any patent, copyright, trade secret or other
 * intellectual property right is granted to or conferred upon you
 * by disclosure or delivery of the Materials, either expressly, by
 * implication, inducement, estoppel or otherwise. Any license
 * under such intellectual property rights must be express and
 * approved by Intel in writing.
 * 
 * $Workfile: ILibAsyncSocket.c
 * $Revision: #1.0.1868.18043
 * $Author:   Intel Corporation, Intel Device Builder
 * $Date:     vendredi 21 janvier 2011
 *
 *
 *
 */

#ifdef MEMORY_CHECK
	#include <assert.h>
	#define MEMCHECK(x) x
#else
	#define MEMCHECK(x)
#endif

#if defined(WIN32)
	#define _CRTDBG_MAP_ALLOC
#endif

#if defined(WINSOCK2)
	#include <winsock2.h>
	#include <ws2tcpip.h>
#elif defined(WINSOCK1)
	#include <winsock.h>
	#include <wininet.h>
#endif
#include "ILibParsers.h"
#include "ILibAsyncSocket.h"

#if defined(WIN32)
	#include <crtdbg.h>
#endif


#define DEBUGSTATEMENT(x)


#ifdef SEMAPHORE_TRACKING
#define SEM_TRACK(x) x
void AsyncSocket_TrackLock(const char* MethodName, int Occurance, void *data)
{
	char v[100];

	sprintf(v,"  LOCK[%s, %d] (%x)\r\n",MethodName,Occurance,data);
#ifdef WIN32
	OutputDebugString(v);
#else
	printf(v);
#endif
}
void AsyncSocket_TrackUnLock(const char* MethodName, int Occurance, void *data)
{
	char v[100];

	sprintf(v,"UNLOCK[%s, %d] (%x)\r\n",MethodName,Occurance,data);
#ifdef WIN32
	OutputDebugString(v);
#else
	printf(v);
#endif
}
#else
#define SEM_TRACK(x)
#endif

struct ILibAsyncSocket_SendData
{
	char* buffer;
	int bufferSize;
	int bytesSent;

	int UserFree;
	struct ILibAsyncSocket_SendData *Next;
};

struct ILibAsyncSocketModule
{
	void (*PreSelect)(void* object,fd_set *readset, fd_set *writeset, fd_set *errorset, int* blocktime);
	void (*PostSelect)(void* object,int slct, fd_set *readset, fd_set *writeset, fd_set *errorset);
	void (*Destroy)(void* object);
	void *Chain;

	unsigned int PendingBytesToSend;
	unsigned int TotalBytesSent;

	#ifdef _WIN32_WCE
		SOCKET internalSocket;
	#elif WIN32
		SOCKET internalSocket;
	#elif _POSIX
		int internalSocket;
	#endif

	int RemoteIPAddress;
	int LocalIPAddress;
	ILibAsyncSocket_OnData OnData;
	ILibAsyncSocket_OnConnect OnConnect;
	ILibAsyncSocket_OnDisconnect OnDisconnect;
	ILibAsyncSocket_OnSendOK OnSendOK;
	ILibAsyncSocket_OnInterrupt OnInterrupt;

	ILibAsyncSocket_OnBufferReAllocated OnBufferReAllocated;

	void *LifeTime;

	void *user;
	int IsFree;
	int PAUSE;
	
	int FinConnect;
	int BeginPointer;
	int EndPointer;
	
	char* buffer;
	int MallocSize;
	int InitialSize;

	struct ILibAsyncSocket_SendData *PendingSend_Head;
	struct ILibAsyncSocket_SendData *PendingSend_Tail;
	sem_t SendLock;
};

void ILibAsyncSocket_PostSelect(void* object,int slct, fd_set *readset, fd_set *writeset, fd_set *errorset);
void ILibAsyncSocket_PreSelect(void* object,fd_set *readset, fd_set *writeset, fd_set *errorset, int* blocktime);

//
// An internal method called by Chain as Destroy, to cleanup AsyncSocket
//
// <param name="socketModule">The AsyncSocketModule</param>
void ILibAsyncSocket_Destroy(void *socketModule)
{
	struct ILibAsyncSocketModule* module = (struct ILibAsyncSocketModule*)socketModule;
	struct ILibAsyncSocket_SendData *temp,*current;

	//
	// Close socket if necessary
	//
	if(module->internalSocket!=~0)
	{
		#ifdef _WIN32_WCE
			closesocket(module->internalSocket);
		#elif WIN32
			closesocket(module->internalSocket);
		#elif _POSIX
			close(module->internalSocket);
		#endif
	}
	
	//
	// Call the interrupt event if necessary
	//
	if(module->IsFree==0)
	{
		if(module->OnInterrupt!=NULL)
		{
			module->OnInterrupt(module,module->user);
		}
	}

	//
	// Free the buffer if necessary
	//
	if(module->buffer!=NULL)
	{
		free(module->buffer);
		module->buffer = NULL;
		module->MallocSize = 0;
	}
	
	//
	// Clear all the data that is pending to be sent
	//
	temp=current=module->PendingSend_Head;
	while(current!=NULL)
	{
		temp = current->Next;
		if(current->UserFree==0)
		{
			free(current->buffer);
		}
		free(current);
		current = temp;
	}
	
	sem_destroy(&(module->SendLock));
}

void ILibAsyncSocket_SetReAllocateNotificationCallback(void *AsyncSocketToken, ILibAsyncSocket_OnBufferReAllocated Callback)
{
	((struct ILibAsyncSocketModule*)AsyncSocketToken)->OnBufferReAllocated = Callback;
}

/*! \fn ILibCreateAsyncSocketModule(void *Chain, int initialBufferSize, ILibAsyncSocket_OnData OnData, ILibAsyncSocket_OnConnect OnConnect, ILibAsyncSocket_OnDisconnect OnDisconnect,ILibAsyncSocket_OnSendOK OnSendOK)
	\brief Creates a new AsyncSocketModule
	\param Chain The ILibLifeTime object to add the timed callback to
	\param initialBufferSize The initial size of the receive buffer
	\param OnData Function Pointer that triggers when Data is received
	\param OnConnect Function Pointer that triggers upon successfull connection establishment
	\param OnDisconnect Function Pointer that triggers upon disconnect
	\param OnSendOK Function Pointer that triggers when pending sends are complete
	\returns An ILibAsyncSocket token
*/
ILibAsyncSocket_SocketModule ILibCreateAsyncSocketModule(void *Chain, int initialBufferSize, ILibAsyncSocket_OnData OnData, ILibAsyncSocket_OnConnect OnConnect, ILibAsyncSocket_OnDisconnect OnDisconnect,ILibAsyncSocket_OnSendOK OnSendOK)
{
	struct ILibAsyncSocketModule *RetVal = (struct ILibAsyncSocketModule*)malloc(sizeof(struct ILibAsyncSocketModule));
	memset(RetVal,0,sizeof(struct ILibAsyncSocketModule));
	RetVal->PreSelect = &ILibAsyncSocket_PreSelect;
	RetVal->PostSelect = &ILibAsyncSocket_PostSelect;
	RetVal->Destroy = &ILibAsyncSocket_Destroy;
	
	RetVal->IsFree = 1;
	RetVal->internalSocket = -1;
	RetVal->OnData = OnData;
	RetVal->OnConnect = OnConnect;
	RetVal->OnDisconnect = OnDisconnect;
	RetVal->OnSendOK = OnSendOK;
	RetVal->buffer = (char*)malloc(initialBufferSize);
	RetVal->InitialSize = initialBufferSize;
	RetVal->MallocSize = initialBufferSize;

	RetVal->LifeTime = ILibCreateLifeTime(Chain);

	sem_init(&(RetVal->SendLock),0,1);
	
	RetVal->Chain = Chain;
	ILibAddToChain(Chain,RetVal);

	return((void*)RetVal);
}

/*! \fn ILibAsyncSocket_ClearPendingSend(ILibAsyncSocket_SocketModule socketModule)
	\brief Clears all the pending data to be sent for an AsyncSocket
	\param socketModule The ILibAsyncSocket to clear
*/
void ILibAsyncSocket_ClearPendingSend(ILibAsyncSocket_SocketModule socketModule)
{
	struct ILibAsyncSocketModule *module = (struct ILibAsyncSocketModule*)socketModule;
	struct ILibAsyncSocket_SendData *data,*temp;
	
	data = module->PendingSend_Head;
	module->PendingSend_Tail = NULL;
	while(data!=NULL)
	{
		temp = data->Next;
		if(data->UserFree==0)
		{
			//
			// We only need to free this if we have ownership of this memory
			//
			free(data->buffer);
		}
		free(data);
		data = temp;
	}
	module->PendingSend_Head = NULL;
	module->PendingBytesToSend=0;
}

/*! \fn ILibAsyncSocket_Send(ILibAsyncSocket_SocketModule socketModule, char* buffer, int length, enum ILibAsyncSocket_MemoryOwnership UserFree)
	\brief Sends data on an AsyncSocket module
	\param socketModule The ILibAsyncSocket module to send data on
	\param buffer The buffer to send
	\param length The length of the buffer to send
	\param UserFree Flag indicating memory ownership. 
	\returns 0 if send completed, nonzero otherwise. (Usually indicates the send was queued)
*/
int ILibAsyncSocket_Send(ILibAsyncSocket_SocketModule socketModule, char* buffer, int length, enum ILibAsyncSocket_MemoryOwnership UserFree)
{
	struct ILibAsyncSocketModule *module = (struct ILibAsyncSocketModule*)socketModule;
	struct ILibAsyncSocket_SendData *data = (struct ILibAsyncSocket_SendData*)malloc(sizeof(struct ILibAsyncSocket_SendData));
	int unblock=0;
	int bytesSent;

	data->buffer = buffer;
	data->bufferSize = length;
	data->bytesSent = 0;
	data->UserFree = UserFree;
	data->Next = NULL;

	SEM_TRACK(AsyncSocket_TrackLock("ILibAsyncSocket_Send",1,module);)
	sem_wait(&(module->SendLock));
	if(module->internalSocket==~0)
	{
		// Too Bad, the socket closed
		if(UserFree==0){free(buffer);}
		free(data);
		SEM_TRACK(AsyncSocket_TrackUnLock("ILibAsyncSocket_Send",2,module);)
		sem_post(&(module->SendLock));
		return(ILibAsyncSocket_SEND_ON_CLOSED_SOCKET_ERROR);
	}

	module->PendingBytesToSend += length;
	if(module->PendingSend_Tail!=NULL)
	{
		//
		// There are still bytes that are pending to be sent, so we need to queue this up
		//
		module->PendingSend_Tail->Next = data;
		module->PendingSend_Tail = data;
		unblock=1;
		if(UserFree==ILibAsyncSocket_MemoryOwnership_USER)
		{
			//
			// If we don't own this memory, we need to copy the buffer,
			// because the user may free this memory before we have a chance
			// to send it
			//
			data->buffer = (char*)malloc(data->bufferSize);
			memcpy(data->buffer,buffer,length);
			MEMCHECK(assert(length <= data->bufferSize);)

			data->UserFree = ILibAsyncSocket_MemoryOwnership_CHAIN;
		}
	}
	else
	{
		//
		// There is no data pending to be sent, so lets go ahead and try to send it
		//
		module->PendingSend_Tail = data;
		module->PendingSend_Head = data;
		
		bytesSent = send(module->internalSocket,module->PendingSend_Head->buffer+module->PendingSend_Head->bytesSent,module->PendingSend_Head->bufferSize-module->PendingSend_Head->bytesSent,0);
		if(bytesSent>0)
		{
			//
			// We were able to send something, so lets increment the counters
			//
			module->PendingSend_Head->bytesSent+=bytesSent;
			module->PendingBytesToSend -= bytesSent;
			module->TotalBytesSent += bytesSent;
		}
		if(bytesSent==-1)
		{
			// 
			// Send returned an error, so lets figure out what it was,
			// as it could be normal
			//
#ifdef _WIN32_WCE
			bytesSent = WSAGetLastError();
			if(bytesSent!=WSAEWOULDBLOCK)
#elif WIN32
			bytesSent = WSAGetLastError();
			if(bytesSent!=WSAEWOULDBLOCK)
#else
			if(errno!=EWOULDBLOCK)
#endif
			{
				//
				// Most likely the socket closed while we tried to send
				//
				if(UserFree==0){free(buffer);}
				module->PendingSend_Head = module->PendingSend_Tail = NULL;
				free(data);
				SEM_TRACK(AsyncSocket_TrackUnLock("ILibAsyncSocket_Send",3,module);)
				sem_post(&(module->SendLock));
				
				//
				//Ensure Calling On_Disconnect with MicroStackThread
				//
				ILibLifeTime_Add(module->LifeTime,socketModule,0,&ILibAsyncSocket_Disconnect,NULL);
				
				return(ILibAsyncSocket_SEND_ON_CLOSED_SOCKET_ERROR);
			}
		}
		if(module->PendingSend_Head->bytesSent==module->PendingSend_Head->bufferSize)
		{
			//
			// All of the data has been sent
			//
			if(UserFree==0){free(module->PendingSend_Head->buffer);}
			module->PendingSend_Tail = NULL;
			free(module->PendingSend_Head);
			module->PendingSend_Head = NULL;
		}
		else
		{
			//
			// All of the data wasn't sent, so we need to copy the buffer
			// if we don't own the memory, because the user may free the
			// memory, before we have a chance to complete sending it.
			//
			if(UserFree==ILibAsyncSocket_MemoryOwnership_USER)
			{
				data->buffer = (char*)malloc(data->bufferSize);
				memcpy(data->buffer,buffer,length);
				MEMCHECK(assert(length <= data->bufferSize);)

				data->UserFree = ILibAsyncSocket_MemoryOwnership_CHAIN;
			}
			unblock = 1;
		}

	}
	SEM_TRACK(AsyncSocket_TrackUnLock("ILibAsyncSocket_Send",4,module);)
	sem_post(&(module->SendLock));
	if(unblock!=0) {ILibForceUnBlockChain(module->Chain);}
	return(unblock);
}

/*! \fn ILibAsyncSocket_Disconnect(ILibAsyncSocket_SocketModule socketModule)
	\brief Disconnects an ILibAsyncSocket
	\param socketModule The ILibAsyncSocket to disconnect
*/
void ILibAsyncSocket_Disconnect(ILibAsyncSocket_SocketModule socketModule)
{
	#ifdef _WIN32_WCE
		SOCKET s;
	#elif WIN32
		SOCKET s;
	#elif _POSIX
		int s;
	#endif

	struct ILibAsyncSocketModule *module = (struct ILibAsyncSocketModule*)socketModule;

	SEM_TRACK(AsyncSocket_TrackLock("ILibAsyncSocket_Disconnect",1,module);)
	sem_wait(&(module->SendLock));
	
	if(module->internalSocket!=~0)
	{
		//
		// There is an associated socket that is still valid, so we need to close it
		//
		module->IsFree = 1;
		module->PAUSE = 1;
		s = module->internalSocket;
		module->internalSocket = ~0;
		if(s!=-1)
		{
			#ifdef _WIN32_WCE
					closesocket(s);
			#elif WIN32
					closesocket(s);
			#elif _POSIX
					close(s);
			#endif
		}

		//
		// Since the socket is closing, we need to clear the data that is pending to be sent
		//
		ILibAsyncSocket_ClearPendingSend(socketModule);
		SEM_TRACK(AsyncSocket_TrackUnLock("ILibAsyncSocket_Disconnect",2,module);)
		sem_post(&(module->SendLock));
		if(module->OnDisconnect!=NULL)
		{
			//
			// Trigger the OnDissconnect event if necessary
			//
			module->OnDisconnect(module,module->user);
		}
	}
	else
	{
		SEM_TRACK(AsyncSocket_TrackUnLock("ILibAsyncSocket_Disconnect",3,module);)
		sem_post(&(module->SendLock));
	}
}

/*! \fn ILibAsyncSocket_ConnectTo(ILibAsyncSocket_SocketModule socketModule, int localInterface, int remoteInterface, int remotePortNumber, ILibAsyncSocket_OnInterrupt InterruptPtr,void *user)
	\brief Attempts to establish a TCP connection
	\param socketModule The ILibAsyncSocket to initiate the connection
	\param localInterface The interface to use to establish the connection
	\param remoteInterface The remote interface to connect to
	\param remotePortNumber The remote port to connect to
	\param InterruptPtr Function Pointer that triggers if connection attempt is interrupted
	\param user User object that will be passed to the \a OnConnect method
*/
void ILibAsyncSocket_ConnectTo(void* socketModule, int localInterface, int remoteInterface, int remotePortNumber, ILibAsyncSocket_OnInterrupt InterruptPtr,void *user)
{
	int flags;
	struct sockaddr_in addr;
	struct ILibAsyncSocketModule *module = (struct ILibAsyncSocketModule*)socketModule;
	
	module->PendingBytesToSend = 0;
	module->TotalBytesSent = 0;
	module->IsFree = 0;
	module->PAUSE = 0;
	module->user = user;
	module->OnInterrupt = InterruptPtr;
	module->buffer = (char*)realloc(module->buffer,module->InitialSize);
	module->MallocSize = module->InitialSize;
	memset((char *)&addr, 0,sizeof(addr));
	addr.sin_family = AF_INET;
	addr.sin_addr.s_addr = remoteInterface;

	#ifdef _WIN32_WCE
		addr.sin_port = htons((unsigned short)remotePortNumber);
	#elif WIN32
		addr.sin_port = htons(remotePortNumber);
	#elif _POSIX
		addr.sin_port = htons(remotePortNumber);
	#endif
	
	//
	// If there isn't a socket already allocated, we need to allocate one
	//
	if(module->internalSocket==-1)
	{
		#ifdef WINSOCK2
			ILibGetStreamSocket(localInterface,0,(HANDLE*)&(module->internalSocket));
		#else
			ILibGetStreamSocket(localInterface,0,&(module->internalSocket));
		#endif
	}
	
	//
	// Initialise the buffer pointers, since no data is in them yet.
	//
	module->FinConnect = 0;
	module->BeginPointer = 0;
	module->EndPointer = 0;
	
	//
	// Set the socket to non-blocking mode, because we need to play nice
	// and share the MicroStack thread
	//
	#ifdef _WIN32_WCE
		flags = 1;
		ioctlsocket(module->internalSocket,FIONBIO,&flags);
	#elif WIN32
		flags = 1;
		ioctlsocket(module->internalSocket,FIONBIO,&flags);
	#elif _POSIX
		flags = fcntl(module->internalSocket,F_GETFL,0);
		fcntl(module->internalSocket,F_SETFL,O_NONBLOCK|flags);
	#endif

	//
	// Connect the socket, and force the chain to unblock, since the select statement
	// doesn't have us in the fdset yet.
	//
	connect(module->internalSocket,(struct sockaddr*)&addr,sizeof(addr));
	ILibForceUnBlockChain(module->Chain);
}

//
// Internal method called when data is ready to be processed on an ILibAsyncSocket
//
// <param name="Reader">The ILibAsyncSocket with pending data</param>
void ILibProcessAsyncSocket(struct ILibAsyncSocketModule *Reader)
{
	int bytesReceived;
	char *temp;

	//
	// If the thing isn't paused, and the user set the pointers such that we still have data
	// in our buffers, we need to call the user back with that data, before we attempt to read
	// more data off the network
	//
	while(Reader->PAUSE==0 && Reader->BeginPointer!=Reader->EndPointer && Reader->BeginPointer!=0)
	{
		memmove(Reader->buffer,Reader->buffer+Reader->BeginPointer,Reader->EndPointer-Reader->BeginPointer);
		MEMCHECK(assert(Reader->EndPointer-Reader->BeginPointer <= Reader->MallocSize);)
		
		Reader->EndPointer = Reader->EndPointer-Reader->BeginPointer;
		Reader->BeginPointer = 0;
		if(Reader->OnData!=NULL)
		{
			Reader->OnData(Reader,Reader->buffer,&(Reader->BeginPointer),Reader->EndPointer,&(Reader->OnInterrupt),&(Reader->user),&(Reader->PAUSE));
		}
	}
	if(Reader->PAUSE!=0)
	{
		return;
	}

	
	/* Reading Body Only */
	if(Reader->BeginPointer == Reader->EndPointer)
	{
		Reader->BeginPointer = 0;
		Reader->EndPointer = 0;
	}
	else
	{
		if(Reader->BeginPointer!=0)
		{
			Reader->EndPointer = Reader->BeginPointer;
		}
	}
	
	bytesReceived = recv(Reader->internalSocket,Reader->buffer+Reader->EndPointer,Reader->MallocSize-Reader->EndPointer,0);
	
	if(bytesReceived<=0)
	{
		//
		// This means the socket was gracefully closed by the remote endpoint
		//
		Reader->IsFree = 1;
		SEM_TRACK(AsyncSocket_TrackLock("ILibProcessAsyncSocket",1,Reader);)
		sem_wait(&(Reader->SendLock));
		ILibAsyncSocket_ClearPendingSend(Reader);
		SEM_TRACK(AsyncSocket_TrackUnLock("ILibProcessAsyncSocket",2,Reader);)
		sem_post(&(Reader->SendLock));

		#ifdef _WIN32_WCE
			closesocket(Reader->internalSocket);
		#elif WIN32
			closesocket(Reader->internalSocket);
		#elif _POSIX
			close(Reader->internalSocket);
		#endif

		Reader->internalSocket = ~0;
		Reader->IsFree = 1;

		//
		// Inform the user the socket has closed
		//
		if(Reader->OnDisconnect!=NULL)
		{
			Reader->OnDisconnect(Reader,Reader->user);
		}

		//
		// If we need to free the buffer, do so
		//
		if(Reader->IsFree!=0 && Reader->buffer!=NULL)
		{
			free(Reader->buffer);
			Reader->buffer = NULL;
			Reader->MallocSize = 0;
		}
	}
	else
	{
		//
		// Data was read, so increment our counters
		//
		Reader->EndPointer += bytesReceived;

		//
		// Tell the user we have some data
		//
		if(Reader->OnData!=NULL)
		{
			Reader->OnData(Reader,Reader->buffer,&(Reader->BeginPointer),Reader->EndPointer,&(Reader->OnInterrupt),&(Reader->user),&(Reader->PAUSE));
		}
		//
		// If the user set the pointers, and we still have data, call them back with the data
		//
		while(Reader->PAUSE==0 && Reader->BeginPointer!=Reader->EndPointer && Reader->BeginPointer!=0)
		{
			memmove(Reader->buffer,Reader->buffer+Reader->BeginPointer,Reader->EndPointer-Reader->BeginPointer);
			MEMCHECK(assert(Reader->EndPointer-Reader->BeginPointer <= Reader->MallocSize);)
			
			Reader->EndPointer = Reader->EndPointer-Reader->BeginPointer;
			Reader->BeginPointer = 0;
			if(Reader->OnData!=NULL)
			{
				Reader->OnData(Reader,Reader->buffer,&(Reader->BeginPointer),Reader->EndPointer,&(Reader->OnInterrupt),&(Reader->user),&(Reader->PAUSE));
			}
		}
		
		//
		// If the user consumed all of the buffer, we can recycle it
		//
		if(Reader->BeginPointer==Reader->EndPointer)
		{
			Reader->BeginPointer = 0;
			Reader->EndPointer = 0;
		}
		
		//
		// If we need to grow the buffer, do it now
		//
		if(Reader->MallocSize - Reader->EndPointer <1024)
		{
			//
			// This memory reallocation sometimes causes Insure++
			// to incorrectly report a READ_DANGLING (usually in 
			// a call to ILibWebServer_StreamHeader_Raw.)
			// 
			// We verified that the problem is with Insure++ by
			// noting the value of 'temp' (0x008fa8e8), 
			// 'Reader->buffer' (0x00c55e80), and
			// 'MEMORYCHUNKSIZE' (0x00001800).
			//
			// When Insure++ reported the error, it (incorrectly) 
			// claimed that a pointer to memory address 0x00c55ea4
			// was invalid, while (correctly) citing the old memory
			// (0x008fa8e8-0x008fb0e7) as freed memory.
			// Normally Insure++ reports that the invalid pointer 
			// is pointing to someplace in the deallocated block,
			// but that wasn't the case.
			//
			Reader->MallocSize += MEMORYCHUNKSIZE;
			temp = Reader->buffer;
			Reader->buffer = (char*)realloc(Reader->buffer,Reader->MallocSize);
			//
			// If this realloc moved the buffer somewhere, we need to inform people of it
			//
			if(Reader->buffer!=temp && Reader->OnBufferReAllocated!=NULL)
			{
				Reader->OnBufferReAllocated(Reader,Reader->user,Reader->buffer-temp);
			}
		}
	}
}

/*! \fn ILibAsyncSocket_GetUser(ILibAsyncSocket_SocketModule socketModule)
	\brief Returns the user object
	\param socketModule The ILibAsyncSocket token to fetch the user object from
	\returns The user object
*/
void * ILibAsyncSocket_GetUser(ILibAsyncSocket_SocketModule socketModule)
{
	return(((struct ILibAsyncSocketModule*)socketModule)->user);
}
//
// Chained PreSelect handler for ILibAsyncSocket
//
// <param name="readset"></param>
// <param name="writeset"></param>
// <param name="errorset"></param>
// <param name="blocktime"></param>
void ILibAsyncSocket_PreSelect(void* socketModule,fd_set *readset, fd_set *writeset, fd_set *errorset, int* blocktime)
{
	struct ILibAsyncSocketModule *module = (struct ILibAsyncSocketModule*)socketModule;

	if(module->internalSocket!=-1)
	{
		if(module->FinConnect==0)
		{
			/* Not Connected Yet */
			FD_SET(module->internalSocket,writeset);
			FD_SET(module->internalSocket,errorset);
		}
		else
		{
			if(module->PAUSE==0)
			{
				/* Already Connected, just needs reading */
				FD_SET(module->internalSocket,readset);
				FD_SET(module->internalSocket,errorset);
			}
		}
	}

	SEM_TRACK(AsyncSocket_TrackLock("ILibAsyncSocket_PreSelect",1,module);)
	sem_wait(&(module->SendLock));
	if(module->PendingSend_Head!=NULL)
	{
		//
		// If there is pending data to be sent, then we need to check when the socket is writable
		//
		FD_SET(module->internalSocket,writeset);
	}
	SEM_TRACK(AsyncSocket_TrackUnLock("ILibAsyncSocket_PreSelect",2,module);)
	sem_post(&(module->SendLock));
}
//
// Chained PostSelect handler for ILibAsyncSocket
//
// <param name="socketModule"></param>
// <param name="slct"></param>
// <param name="readset"></param>
// <param name="writeset"></param>
// <param name="errorset"></param>
void ILibAsyncSocket_PostSelect(void* socketModule,int slct, fd_set *readset, fd_set *writeset, fd_set *errorset)
{
	int TriggerSendOK = 0;
	struct ILibAsyncSocket_SendData *temp;
	int bytesSent=0;
	int flags;
	struct sockaddr_in receivingAddress;
	int receivingAddressLength = sizeof(struct sockaddr_in);
	struct ILibAsyncSocketModule *module = (struct ILibAsyncSocketModule*)socketModule;
	int TRY_TO_SEND = 1;
	
	// Write Handling
	if(module->FinConnect!=0 && module->internalSocket!=~0 && FD_ISSET(module->internalSocket,writeset)!=0)
	{
		//
		// The socket is writable, and data needs to be sent
		//
		SEM_TRACK(AsyncSocket_TrackLock("ILibAsyncSocket_PostSelect",1,module);)
		sem_wait(&(module->SendLock));
		//
		// Keep trying to send data, until we are told we can't
		//
		while(TRY_TO_SEND!=0)
		{
			bytesSent = send(module->internalSocket,module->PendingSend_Head->buffer+module->PendingSend_Head->bytesSent,module->PendingSend_Head->bufferSize-module->PendingSend_Head->bytesSent,0);
			if(bytesSent>0)
			{
				module->PendingBytesToSend -= bytesSent;
				module->TotalBytesSent += bytesSent;
				module->PendingSend_Head->bytesSent+=bytesSent;
				if(module->PendingSend_Head->bytesSent==module->PendingSend_Head->bufferSize)
				{
					// Finished Sending this block
					if(module->PendingSend_Head==module->PendingSend_Tail)
					{
						module->PendingSend_Tail = NULL;
					}
					if(module->PendingSend_Head->UserFree==0)
					{
						free(module->PendingSend_Head->buffer);
					}
					temp = module->PendingSend_Head->Next;
					free(module->PendingSend_Head);
					module->PendingSend_Head = temp;
					if(module->PendingSend_Head==NULL) {TRY_TO_SEND=0;}
				}
				else
				{
					//
					// We sent data, but not everything that needs to get sent was sent, try again
					//
					TRY_TO_SEND = 1;
				}
			}
			if(bytesSent==-1)
			{
				// Error, clean up everything
				TRY_TO_SEND = 0;
				#ifdef _WIN32_WCE
					bytesSent = WSAGetLastError();
					if(bytesSent!=WSAEWOULDBLOCK)
				#elif WIN32
					bytesSent = WSAGetLastError();
					if(bytesSent!=WSAEWOULDBLOCK)
				#else
					if(errno!=EWOULDBLOCK)
				#endif
				{
					//
					// There was an error sending
					//
					ILibAsyncSocket_ClearPendingSend(socketModule);
				}
			}
		}
		//
		// This triggers OnSendOK, if all the pending data has been sent.
		//
		if(module->PendingSend_Head==NULL && bytesSent!=-1) {TriggerSendOK=1;}
		SEM_TRACK(AsyncSocket_TrackUnLock("ILibAsyncSocket_PostSelect",2,module);)
		sem_post(&(module->SendLock));
		if(TriggerSendOK!=0)
		{
			module->OnSendOK(module,module->user);
		}
	}

	//
	// Connection Handling / Read Handling
	//
	if(module->internalSocket!=~0)
	{
		if(module->FinConnect==0)
		{
			/* Not Connected Yet */
			if(FD_ISSET(module->internalSocket,writeset)!=0)
			{
				/* Connected */
				getsockname(module->internalSocket,(struct sockaddr*)&receivingAddress,&receivingAddressLength);
				module->LocalIPAddress = receivingAddress.sin_addr.s_addr;
				module->FinConnect = 1;
				module->PAUSE = 0;
				
				//
				// Set the socket to non-blocking mode, so we can play nice and share the thread
				//
				#ifdef _WIN32_WCE
					flags = 1;
					ioctlsocket(module->internalSocket,FIONBIO,&flags);
				#elif WIN32
					flags = 1;
					ioctlsocket(module->internalSocket,FIONBIO,&flags);
				#elif _POSIX
					flags = fcntl(module->internalSocket,F_GETFL,0);
					fcntl(module->internalSocket,F_SETFL,O_NONBLOCK|flags);
				#endif

				/* Connection Complete */
				if(module->OnConnect!=NULL)
				{
					module->OnConnect(module,-1,module->user);
				}
			}
			if(FD_ISSET(module->internalSocket,errorset)!=0)
			{
				/* Connection Failed */
				#ifdef _WIN32_WCE
					closesocket(module->internalSocket);
				#elif WIN32
					closesocket(module->internalSocket);
				#elif _POSIX
					close(module->internalSocket);
				#endif
				module->internalSocket = ~0;
				module->IsFree = 1;
				if(module->OnConnect!=NULL)
				{
					module->OnConnect(module,0,module->user);
				}
			}
		}
		else
		{
			/* Check if PeerReset */
			if(FD_ISSET(module->internalSocket,errorset)!=0)
			{
				/* Socket Closed */
				#ifdef _WIN32_WCE
					closesocket(module->internalSocket);
				#elif WIN32
					closesocket(module->internalSocket);
				#elif _POSIX
					close(module->internalSocket);
				#endif
				module->internalSocket = ~0;
				module->IsFree=1;
				module->PAUSE = 1;
				SEM_TRACK(AsyncSocket_TrackLock("ILibAsyncSocket_PostSelect",3,module);)
				sem_wait(&(module->SendLock));
				ILibAsyncSocket_ClearPendingSend(socketModule);
				SEM_TRACK(AsyncSocket_TrackUnLock("ILibAsyncSocket_PostSelect",4,module);)
				sem_post(&(module->SendLock));
				if(module->OnDisconnect!=NULL)
				{
					module->OnDisconnect(module,module->user);
				}
			}
			/* Already Connected, just needs reading */
			if(FD_ISSET(module->internalSocket,readset)!=0)
			{
				/* Data Available */
				ILibProcessAsyncSocket(module);
			}
		}
	}
}

/*! \fn ILibAsyncSocket_IsFree(ILibAsyncSocket_SocketModule socketModule)
	\brief Determines if an ILibAsyncSocket is in use
	\param socketModule The ILibAsyncSocket to query</param>
	\returns 0 if in use, nonzero otherwise
*/
int ILibAsyncSocket_IsFree(ILibAsyncSocket_SocketModule socketModule)
{
	struct ILibAsyncSocketModule *module = (struct ILibAsyncSocketModule*)socketModule;
	return(module->IsFree);
}

/*! \fn ILibAsyncSocket_GetPendingBytesToSend(ILibAsyncSocket_SocketModule socketModule)
	\brief Returns the number of bytes that are pending to be sent
	\param socketModule The ILibAsyncSocket to query
	\returns Number of pending bytes
*/
unsigned int ILibAsyncSocket_GetPendingBytesToSend(ILibAsyncSocket_SocketModule socketModule)
{
	struct ILibAsyncSocketModule *module = (struct ILibAsyncSocketModule*)socketModule;
	return(module->PendingBytesToSend);
}

/*! \fn ILibAsyncSocket_GetTotalBytesSent(ILibAsyncSocket_SocketModule socketModule)
	\brief Returns the total number of bytes that have been sent, since the last reset
	\param socketModule The ILibAsyncSocket to query
	\returns Number of bytes sent
*/
unsigned int ILibAsyncSocket_GetTotalBytesSent(ILibAsyncSocket_SocketModule socketModule)
{
	struct ILibAsyncSocketModule *module = (struct ILibAsyncSocketModule*)socketModule;
    return(module->TotalBytesSent);
}

/*! \fn ILibAsyncSocket_ResetTotalBytesSent(ILibAsyncSocket_SocketModule socketModule)
	\brief Resets the total bytes sent counter
	\param socketModule The ILibAsyncSocket to reset
*/
void ILibAsyncSocket_ResetTotalBytesSent(ILibAsyncSocket_SocketModule socketModule)
{
	struct ILibAsyncSocketModule *module = (struct ILibAsyncSocketModule*)socketModule;
	module->TotalBytesSent = 0;
}

/*! \fn ILibAsyncSocket_GetBuffer(ILibAsyncSocket_SocketModule socketModule, char **buffer, int *BeginPointer, int *EndPointer)
	\brief Returns the buffer associated with an ILibAsyncSocket
	\param socketModule The ILibAsyncSocket to obtain the buffer from
	\param[out] buffer The buffer
	\param[out] BeginPointer Stating offset of the buffer
	\param[out] EndPointer Length of buffer
*/
void ILibAsyncSocket_GetBuffer(ILibAsyncSocket_SocketModule socketModule, char **buffer, int *BeginPointer, int *EndPointer)
{
	struct ILibAsyncSocketModule* module = (struct ILibAsyncSocketModule*)socketModule;

	*buffer = module->buffer;
	*BeginPointer = module->BeginPointer;
	*EndPointer = module->EndPointer;
}

//
// Sets the remote address field
//
// This is utilized by the ILibAsyncServerSocket module
// <param name="socketModule">The ILibAsyncSocket to modify</param>
// <param name="RemoteAddress">The remote interface</param>
void ILibAsyncSocket_SetRemoteAddress(ILibAsyncSocket_SocketModule socketModule,int RemoteAddress)
{
	struct ILibAsyncSocketModule* module = (struct ILibAsyncSocketModule*)socketModule;
	module->RemoteIPAddress = RemoteAddress;
}

/*! \fn ILibAsyncSocket_UseThisSocket(ILibAsyncSocket_SocketModule socketModule,void* UseThisSocket,ILibAsyncSocket_OnInterrupt InterruptPtr,void *user)
	\brief Associates an actual socket with ILibAsyncSocket
	\para
	Instead of calling \a ConnectTo, you can call this method to associate with an already
	connected socket.
	\param socketModule The ILibAsyncSocket to associate
	\param UseThisSocket The socket to associate
	\param InterruptPtr Function Pointer that triggers when the TCP connection is interrupted
	\param user User object to associate with this session
*/
void ILibAsyncSocket_UseThisSocket(ILibAsyncSocket_SocketModule socketModule,void* UseThisSocket,ILibAsyncSocket_OnInterrupt InterruptPtr,void *user)
{
	#ifdef _WIN32_WCE
		SOCKET TheSocket = *((SOCKET*)UseThisSocket);
	#elif WIN32
		SOCKET TheSocket = *((SOCKET*)UseThisSocket);
	#elif _POSIX
		int TheSocket = *((int*)UseThisSocket);
	#endif
	int flags;
	struct ILibAsyncSocketModule* module = (struct ILibAsyncSocketModule*)socketModule;
	module->PendingBytesToSend = 0;
	module->TotalBytesSent = 0;
	module->internalSocket = TheSocket;
	module->IsFree = 0;
	module->OnInterrupt = InterruptPtr;
	module->user = user;
	module->FinConnect = 1;
	module->PAUSE = 0;

	//
	// If the buffer is too small/big, we need to realloc it to the minimum specified size
	//
	module->buffer = (char*)realloc(module->buffer,module->InitialSize);
	module->MallocSize = module->InitialSize;
	module->FinConnect = 1;
	module->BeginPointer = 0;
	module->EndPointer = 0;

	//
	// Make sure the socket is non-blocking, so we can play nice and share the thread
	//
	#ifdef _WIN32_WCE
		flags = 1;
		ioctlsocket(module->internalSocket,FIONBIO,&flags);
	#elif WIN32
		flags = 1;
		ioctlsocket(module->internalSocket,FIONBIO,&flags);
	#elif _POSIX
		flags = fcntl(module->internalSocket,F_GETFL,0);
		fcntl(module->internalSocket,F_SETFL,O_NONBLOCK|flags);
	#endif
}

/*! \fn ILibAsyncSocket_GetRemoteInterface(ILibAsyncSocket_SocketModule socketModule)
	\brief Returns the Remote Interface of a connected session
	\param socketModule The ILibAsyncSocket to query
	\returns The remote interface
*/
int ILibAsyncSocket_GetRemoteInterface(ILibAsyncSocket_SocketModule socketModule)
{
	struct ILibAsyncSocketModule *module = (struct ILibAsyncSocketModule*)socketModule;
	return(module->RemoteIPAddress);
}

/*! \fn ILibAsyncSocket_GetLocalInterface(ILibAsyncSocket_SocketModule socketModule)
	\brief Returns the Local Interface of a connected session
	\param socketModule The ILibAsyncSocket to query
	\returns The local interface
*/
int ILibAsyncSocket_GetLocalInterface(ILibAsyncSocket_SocketModule socketModule)
{
	struct ILibAsyncSocketModule *module = (struct ILibAsyncSocketModule*)socketModule;
	struct sockaddr_in receivingAddress;
	int receivingAddressLength = sizeof(struct sockaddr_in);

	getsockname(module->internalSocket,(struct sockaddr*)&receivingAddress,&receivingAddressLength);
	return(receivingAddress.sin_addr.s_addr);
}

/*! \fn ILibAsyncSocket_Resume(ILibAsyncSocket_SocketModule socketModule)
	\brief Resumes a paused session
	\para
	Sessions can be paused, such that further data is not read from the socket until resumed
	\param socketModule The ILibAsyncSocket to resume
*/
void ILibAsyncSocket_Resume(ILibAsyncSocket_SocketModule socketModule)
{
	struct ILibAsyncSocketModule *sm = (struct ILibAsyncSocketModule*)socketModule;
	if(sm->PAUSE!=0)
	{
		sm->PAUSE=0;
		ILibForceUnBlockChain(sm->Chain);
	}
}
