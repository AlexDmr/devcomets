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
 * $Workfile: ILibAsyncSocket.h
 * $Revision: #1.0.1868.18043
 * $Author:   Intel Corporation, Intel Device Builder
 * $Date:     vendredi 21 janvier 2011
 *
 *
 *
 */

#ifndef ___ILibAsyncSocket___
#define ___ILibAsyncSocket___

/*! \file ILibAsyncSocket.h 
	\brief MicroStack APIs for TCP Client Functionality
*/

/*! \defgroup ILibAsyncSocket ILibAsyncSocket Module
	\{
*/

#if defined(WIN32) || defined(_WIN32_WCE)
#include <STDDEF.H>
#else
#include <malloc.h>
#endif


/*! \def MEMORYCHUNKSIZE
	\brief Incrementally grow the buffer by this amount of bytes
*/
#define MEMORYCHUNKSIZE 4096

#define ILibAsyncSocket_SEND_ON_CLOSED_SOCKET_ERROR -4

/*! \enum ILibAsyncSocket_MemoryOwnership
	\brief Enumeration values for Memory Ownership of variables
*/
enum ILibAsyncSocket_MemoryOwnership
{
	ILibAsyncSocket_MemoryOwnership_CHAIN=0, /*!< The Microstack will own this memory, and free it when it is done with it */
	ILibAsyncSocket_MemoryOwnership_STATIC=1, /*!< This memory is static, so the Microstack will not free it, and assume it will not go away, so it won't copy it either */
	ILibAsyncSocket_MemoryOwnership_USER=2 /*!< The Microstack doesn't own this memory, so if necessary the memory will be copied */
};


typedef void* ILibAsyncSocket_SocketModule;
typedef void(*ILibAsyncSocket_OnInterrupt)(ILibAsyncSocket_SocketModule socketModule, void *user);
typedef void(*ILibAsyncSocket_OnData)(ILibAsyncSocket_SocketModule socketModule,char* buffer,int *p_beginPointer, int endPointer,ILibAsyncSocket_OnInterrupt* OnInterrupt, void **user, int *PAUSE);
typedef void(*ILibAsyncSocket_OnConnect)(ILibAsyncSocket_SocketModule socketModule, int Connected, void *user);
typedef void(*ILibAsyncSocket_OnDisconnect)(ILibAsyncSocket_SocketModule socketModule, void *user);
typedef void(*ILibAsyncSocket_OnSendOK)(ILibAsyncSocket_SocketModule socketModule, void *user);
typedef void(*ILibAsyncSocket_OnBufferReAllocated)(ILibAsyncSocket_SocketModule AsyncSocketToken, void *user, ptrdiff_t newOffset);




void ILibAsyncSocket_SetReAllocateNotificationCallback(ILibAsyncSocket_SocketModule AsyncSocketToken, ILibAsyncSocket_OnBufferReAllocated Callback);
void * ILibAsyncSocket_GetUser(ILibAsyncSocket_SocketModule socketModule);

ILibAsyncSocket_SocketModule ILibCreateAsyncSocketModule(void *Chain, int initialBufferSize, ILibAsyncSocket_OnData , ILibAsyncSocket_OnConnect OnConnect ,ILibAsyncSocket_OnDisconnect OnDisconnect,ILibAsyncSocket_OnSendOK OnSendOK);
unsigned int ILibAsyncSocket_GetPendingBytesToSend(ILibAsyncSocket_SocketModule socketModule);
unsigned int ILibAsyncSocket_GetTotalBytesSent(ILibAsyncSocket_SocketModule socketModule);
void ILibAsyncSocket_ResetTotalBytesSent(ILibAsyncSocket_SocketModule socketModule);

void ILibAsyncSocket_ConnectTo(ILibAsyncSocket_SocketModule socketModule, int localInterface, int remoteInterface, int remotePortNumber,ILibAsyncSocket_OnInterrupt InterruptPtr, void *user);
int ILibAsyncSocket_Send(ILibAsyncSocket_SocketModule socketModule, char* buffer, int length, enum ILibAsyncSocket_MemoryOwnership UserFree);
void ILibAsyncSocket_Disconnect(ILibAsyncSocket_SocketModule socketModule);
void ILibAsyncSocket_GetBuffer(ILibAsyncSocket_SocketModule socketModule, char **buffer, int *BeginPointer, int *EndPointer);

void ILibAsyncSocket_UseThisSocket(ILibAsyncSocket_SocketModule socketModule,void* TheSocket,ILibAsyncSocket_OnInterrupt InterruptPtr,void *user);
void ILibAsyncSocket_SetRemoteAddress(ILibAsyncSocket_SocketModule socketModule,int RemoteAddress);

int ILibAsyncSocket_IsFree(ILibAsyncSocket_SocketModule socketModule);
int ILibAsyncSocket_GetLocalInterface(ILibAsyncSocket_SocketModule socketModule);
int ILibAsyncSocket_GetRemoteInterface(ILibAsyncSocket_SocketModule socketModule);

void ILibAsyncSocket_Resume(ILibAsyncSocket_SocketModule socketModule);

/*! \} */
#endif
