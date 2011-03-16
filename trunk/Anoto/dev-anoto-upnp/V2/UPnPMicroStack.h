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
 * $Workfile: UPnPMicroStack.h
 * $Revision: #1.0.1868.18043
 * $Author:   Intel Corporation, Intel Device Builder
 * $Date:     vendredi 21 janvier 2011
 *
 *
 *
 */
#ifndef __UPnPMicrostack__
#define __UPnPMicrostack__


#include "ILibAsyncSocket.h"

/*! \file UPnPMicroStack.h 
	\brief MicroStack APIs for Device Implementation
*/

/*! \defgroup MicroStack MicroStack Module
	\{
*/

struct UPnPDataObject;
struct packetheader;

typedef void* UPnPMicroStackToken;
typedef void* UPnPSessionToken;


/* Complex Type Parsers */


/* Complex Type Serializers */



/* UPnP Stack Management */
UPnPMicroStackToken UPnPCreateMicroStack(void *Chain, const char* FriendlyName,const char* UDN, const char* SerialNumber, const int NotifyCycleSeconds, const unsigned short PortNum);


void UPnPIPAddressListChanged(UPnPMicroStackToken MicroStackToken);
int UPnPGetLocalPortNumber(UPnPSessionToken token);
int   UPnPGetLocalInterfaceToHost(const UPnPSessionToken UPnPToken);
void* UPnPGetWebServerToken(const UPnPMicroStackToken MicroStackToken);

/* UPnP Set Function Pointers Methods */
extern void (*UPnPFP_PresentationPage) (void* upnptoken,struct packetheader *packet);
extern void (*UPnPFP_ImportedService_getTcpServer) (void* upnptoken);
extern void (*UPnPFP_ImportedService_setForce) (void* upnptoken,int f);
extern void (*UPnPFP_ImportedService_setPage) (void* upnptoken,char* p);
extern void (*UPnPFP_ImportedService_setSerial) (void* upnptoken,char* s);
extern void (*UPnPFP_ImportedService_setX) (void* upnptoken,int x);
extern void (*UPnPFP_ImportedService_setY) (void* upnptoken,int y);


void UPnPSetDisconnectFlag(UPnPSessionToken token,void *flag);

/* Invocation Response Methods */
void UPnPResponse_Error(const UPnPSessionToken UPnPToken, const int ErrorCode, const char* ErrorMsg);
void UPnPResponseGeneric(const UPnPSessionToken UPnPToken,const char* ServiceURI,const char* MethodName,const char* Params);
void UPnPResponse_ImportedService_getTcpServer(const UPnPSessionToken UPnPToken, const char* a);
void UPnPResponse_ImportedService_setForce(const UPnPSessionToken UPnPToken);
void UPnPResponse_ImportedService_setPage(const UPnPSessionToken UPnPToken);
void UPnPResponse_ImportedService_setSerial(const UPnPSessionToken UPnPToken);
void UPnPResponse_ImportedService_setX(const UPnPSessionToken UPnPToken);
void UPnPResponse_ImportedService_setY(const UPnPSessionToken UPnPToken);


/* State Variable Eventing Methods */
void UPnPSetState_ImportedService_page(UPnPMicroStackToken microstack,char* val);
void UPnPSetState_ImportedService_x(UPnPMicroStackToken microstack,int val);
void UPnPSetState_ImportedService_y(UPnPMicroStackToken microstack,int val);
void UPnPSetState_ImportedService_serial(UPnPMicroStackToken microstack,char* val);
void UPnPSetState_ImportedService_force(UPnPMicroStackToken microstack,int val);


/*! \} */
#endif
