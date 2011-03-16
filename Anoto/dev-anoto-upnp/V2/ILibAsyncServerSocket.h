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
 * $Workfile: ILibAsyncServerSocket.h
 * $Revision: #1.0.1868.18043
 * $Author:   Intel Corporation, Intel Device Builder
 * $Date:     vendredi 21 janvier 2011
 *
 *
 *
 */

#ifndef ___ILibAsyncServerSocket___
#define ___ILibAsyncServerSocket___

/*! \file ILibAsyncServerSocket.h 
	\brief MicroStack APIs for TCP Server Functionality
*/

/*! \defgroup ILibAsyncServerSocket ILibAsyncServerSocket Module
	\{
*/

#if defined(WIN32) || defined(_WIN32_WCE)
#include <STDDEF.H>
#else
#include <malloc.h>
#endif

#include "ILibAsyncSocket.h"

typedef void* ILibAsyncServerSocket_ServerModule;
typedef ILibAsyncSocket_SocketModule ILibAsyncServerSocket_ConnectionToken;

/*! \typedef ILibAsyncServerSocket_BufferReAllocated
	\brief BufferReAllocation Handler
	\param AsyncServerSocketToken The ILibAsyncServerSocket token
	\param ConnectionToken The ILibAsyncServerSocket_Connection token
	\param user The User object
	\param newOffset The buffer has shifted by this offset
*/
typedef void (*ILibAsyncServerSocket_BufferReAllocated)(ILibAsyncServerSocket_ServerModule AsyncServerSocketToken, ILibAsyncServerSocket_ConnectionToken ConnectionToken, void *user, ptrdiff_t newOffset);
void ILibAsyncServerSocket_SetReAllocateNotificationCallback(ILibAsyncServerSocket_ServerModule AsyncServerSocketToken, ILibAsyncServerSocket_ConnectionToken ConnectionToken, ILibAsyncServerSocket_BufferReAllocated Callback);

typedef void (*ILibAsyncServerSocket_OnInterrupt)(ILibAsyncServerSocket_ServerModule AsyncServerSocketModule, ILibAsyncServerSocket_ConnectionToken ConnectionToken, void *user);
typedef void (*ILibAsyncServerSocket_OnReceive)(ILibAsyncServerSocket_ServerModule AsyncServerSocketModule, ILibAsyncServerSocket_ConnectionToken ConnectionToken,char* buffer,int *p_beginPointer, int endPointer, ILibAsyncServerSocket_OnInterrupt *OnInterrupt,void **user, int *PAUSE);
typedef void (*ILibAsyncServerSocket_OnConnect)(ILibAsyncServerSocket_ServerModule AsyncServerSocketModule, ILibAsyncServerSocket_ConnectionToken ConnectionToken,void **user);
typedef void (*ILibAsyncServerSocket_OnDisconnect)(ILibAsyncServerSocket_ServerModule AsyncServerSocketModule, ILibAsyncServerSocket_ConnectionToken ConnectionToken, void *user);
typedef void (*ILibAsyncServerSocket_OnSendOK)(ILibAsyncServerSocket_ServerModule AsyncServerSocketModule, ILibAsyncServerSocket_ConnectionToken ConnectionToken, void *user);



ILibAsyncServerSocket_ServerModule ILibCreateAsyncServerSocketModule(void *Chain, int MaxConnections, int PortNumber, int initialBufferSize, ILibAsyncServerSocket_OnConnect OnConnect,ILibAsyncServerSocket_OnDisconnect OnDisconnect,ILibAsyncServerSocket_OnReceive OnReceive,ILibAsyncServerSocket_OnInterrupt OnInterrupt,ILibAsyncServerSocket_OnSendOK OnSendOK);

void *ILibAsyncServerSocket_GetTag(ILibAsyncServerSocket_ServerModule ILibAsyncSocketModule);
void ILibAsyncServerSocket_SetTag(ILibAsyncServerSocket_ServerModule ILibAsyncSocketModule, void *user);

unsigned short ILibAsyncServerSocket_GetPortNumber(ILibAsyncServerSocket_ServerModule ServerSocketModule);

/*! \def ILibAsyncServerSocket_Send
	\brief Sends data onto the TCP stream
*/
#define ILibAsyncServerSocket_Send(ServerSocketModule, ConnectionToken, buffer, bufferLength, UserFreeBuffer) ILibAsyncSocket_Send(ConnectionToken,buffer,bufferLength,UserFreeBuffer)

/*! \def ILibAsyncServerSocket_Disconnect
	\brief Disconnects a TCP stream
*/
#define ILibAsyncServerSocket_Disconnect(ServerSocketModule, ConnectionToken) ILibAsyncSocket_Disconnect(ConnectionToken)
/*! \def ILibAsyncServerSocket_GetPendingBytesToSend
	\brief Gets the outstanding number of bytes to be sent
*/
#define ILibAsyncServerSocket_GetPendingBytesToSend(ServerSocketModule, ConnectionToken) ILibAsyncSocket_GetPendingBytesToSend(ConnectionToken)
/*! \def ILibAsyncServerSocket_GetTotalBytesSent
	\brief Gets the total number of bytes that have been sent
*/
#define ILibAsyncServerSocket_GetTotalBytesSent(ServerSocketModule, ConnectionToken) ILibAsyncSocket_GetTotalBytesSent(ConnectionToken)
/*! \def ILibAsyncServerSocket_ResetTotalBytesSent
	\brief Resets the total bytes sent counter
*/
#define ILibAsyncServerSocket_ResetTotalBytesSent(ServerSocketModule, ConnectionToken) ILibAsyncSocket_ResetTotalBytesSent(ConnectionToken)

/*! \} */

#endif
