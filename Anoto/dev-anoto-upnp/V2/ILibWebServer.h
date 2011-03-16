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
 * $Workfile: ILibWebServer.h
 * $Revision: #1.0.1868.18043
 * $Author:   Intel Corporation, Intel Device Builder
 * $Date:     vendredi 21 janvier 2011
 *
 *
 *
 */

/*! \file ILibWebServer.h 
	\brief MicroStack APIs for HTTP Server functionality
*/

#ifndef __ILibWebServer__
#define __ILibWebServer__
#include "ILibParsers.h"
#include "ILibAsyncServerSocket.h"

/*! \defgroup ILibWebServer ILibWebServer Module
	\{
*/

/*! \def ILibWebServer_SEND_RESULTED_IN_DISCONNECT
	\brief Return value specifying that the send attemp resulted in a disconnect
*/
#define ILibWebServer_SEND_RESULTED_IN_DISCONNECT -2

/*! \def ILibWebServer_INVALID_SESSION
	\brief Return value specifying that the supplied session is invalid
*/
#define ILibWebServer_INVALID_SESSION -3

typedef void* ILibWebServer_ServerToken;

struct ILibWebServer_Session;

/*! \typedef ILibWebServer_Session_OnReceive
	\brief OnReceive Handler
	\param sender The associate \a ILibWebServer_Session object
	\param InterruptFlag boolean indicating if the underlying chain/thread is disposing
	\param header The HTTP headers that were received
	\param bodyBuffer Pointer to the HTTP body
	\param[in,out] beginPointer Starting offset of the body buffer. Advance this pointer when the data is consumed.
	\param endPointer Length of available data pointed to by \a bodyBuffer
	\param done boolean indicating if the entire packet has been received
*/
typedef void (*ILibWebServer_Session_OnReceive)(struct ILibWebServer_Session *sender, int InterruptFlag, struct packetheader *header, char *bodyBuffer, int *beginPointer, int endPointer, int done);
typedef void (*ILibWebServer_Session_OnDisconnect)(struct ILibWebServer_Session *sender);
typedef	void (*ILibWebServer_Session_OnSendOK)(struct ILibWebServer_Session *sender);

/*! \struct ILibWebServer_Session
	\brief A structure representing the state of an HTTP Session
*/
struct ILibWebServer_Session
{
	/*! \var OnReceive
		\brief A Function Pointer that is triggered whenever data is received
	*/
	ILibWebServer_Session_OnReceive OnReceive;
	/*! \var OnDisconnect
		\brief A Function Pointer that is triggered when the session is disconnected
	*/
	ILibWebServer_Session_OnDisconnect OnDisconnect;
	/*! \var OnSendOK
		\brief A Function Pointer that is triggered when the send buffer is emptied
	*/
	ILibWebServer_Session_OnSendOK OnSendOK;
	void *Parent;

	/*! \var User
		\brief A reserved pointer that you can use for your own use
	*/
	void *User;
	/*! \var User2
		\brief A reserved pointer that you can use for your own use
	*/
	void *User2;
	/*! \var User3
		\brief A reserved pointer that you can use for your own use
	*/
	void *User3;

	void *Reserved1;	// AsyncServerSocket
	void *Reserved2;	// ConnectionToken
	void *Reserved3;	// WebClientDataObject
	void *Reserved7;	// VirtualDirectory
	int Reserved4;	// Request Answered Flag (set by send)
	int Reserved8;	// RequestAnswered Method Called
	int Reserved5;	// Request Made Flag
	int Reserved6;	// Close Override Flag
	int Reserved9;	// Reserved for future use
	void ** Reserved10;	// DisconnectFlagPointer

	sem_t Reserved11;	// Session Lock
	int Reserved12;		// Reference Counter;
};


void ILibWebServer_AddRef(struct ILibWebServer_Session *session);
void ILibWebServer_Release(struct ILibWebServer_Session *session);

/*! \typedef ILibWebServer_Session_OnSession
	\brief New Session Handler
	\param SessionToken The new Session
	\param User The \a User object specified in \a ILibWebServer_Create
*/
typedef void (*ILibWebServer_Session_OnSession)(struct ILibWebServer_Session *SessionToken, void *User);
/*! \typedef ILibWebServer_VirtualDirectory
	\brief Request Handler for a registered Virtual Directory
	\param session The session that received the request
	\param header The HTTP headers
	\param bodyBuffer Pointer to the HTTP body
	\param[in,out] beginPointer Starting index of \a bodyBuffer. Advance this pointer as data is consumed
	\param endPointer Length of available data in \bodyBuffer
	\param done boolean indicating that the entire packet has been read
	\param user The \user specified in \a ILibWebServer_Create
*/
typedef void (*ILibWebServer_VirtualDirectory)(struct ILibWebServer_Session *session, struct packetheader *header, char *bodyBuffer, int *beginPointer, int endPointer, int done, void *user);

void ILibWebServer_SetTag(ILibWebServer_ServerToken WebServerToken, void *Tag);
void *ILibWebServer_GetTag(ILibWebServer_ServerToken WebServerToken);

ILibWebServer_ServerToken ILibWebServer_Create(void *Chain, int MaxConnections, int PortNumber,ILibWebServer_Session_OnSession OnSession, void *User);
int ILibWebServer_RegisterVirtualDirectory(ILibWebServer_ServerToken WebServerToken, char *vd, int vdLength, ILibWebServer_VirtualDirectory OnVirtualDirectory, void *user);
int ILibWebServer_UnRegisterVirtualDirectory(ILibWebServer_ServerToken WebServerToken, char *vd, int vdLength);

int ILibWebServer_Send(struct ILibWebServer_Session *session, struct packetheader *packet);
int ILibWebServer_Send_Raw(struct ILibWebServer_Session *session, char *buffer, int bufferSize, int userFree, int done);

/*! \def ILibWebServer_Session_GetPendingBytesToSend
	\brief Returns the number of outstanding bytes to be sent
*/
#define ILibWebServer_Session_GetPendingBytesToSend(session) ILibAsyncServerSocket_GetPendingBytesToSend(session->Reserved1,session->Reserved2)
/*! \def ILibWebServer_Session_GetTotalBytesSent
	\brief Returns the total number of bytes sent
*/
#define ILibWebServer_Session_GetTotalBytesSent(session) ILibAsyncServerSocket_GetTotalBytesSent(session->Reserved1,session->Reserved2)
/*! \def ILibWebServer_Session_ResetTotalBytesSent
	\brief Resets the total bytes set counter
*/
#define ILibWebServer_Session_ResetTotalBytesSent(session) ILibAsyncServerSocket_ResetTotalBytesSent(session->Reserved1,session->Reserved2)

unsigned short ILibWebServer_GetPortNumber(ILibWebServer_ServerToken WebServerToken);
int ILibWebServer_GetLocalInterface(struct ILibWebServer_Session *session);
int ILibWebServer_GetRemoteInterface(struct ILibWebServer_Session *session);

int ILibWebServer_StreamHeader(struct ILibWebServer_Session *session, struct packetheader *header);
int ILibWebServer_StreamBody(struct ILibWebServer_Session *session, char *buffer, int bufferSize, int userFree, int done);

int ILibWebServer_StreamHeader_Raw(struct ILibWebServer_Session *session, int StatusCode,char *StatusData,char *ResponseHeaders, int ResponseHeaders_FREE);
void ILibWebServer_DisconnectSession(struct ILibWebServer_Session *session);

/* \} */
#endif
