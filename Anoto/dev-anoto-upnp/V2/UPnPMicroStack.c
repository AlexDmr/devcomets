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
* $Workfile: UPnPMicroStack.c
* $Revision: #1.0.1868.18043
* $Author:   Intel Corporation, Intel Device Builder
* $Date:     vendredi 21 janvier 2011
*
*
*
*/


#if defined(WIN32) || defined(_WIN32_WCE)
#	ifndef MICROSTACK_NO_STDAFX
#		include "stdafx.h"
#	endif
char* UPnPPLATFORM = "WINDOWS";
#else
char* UPnPPLATFORM = "POSIX";
#endif

#if defined(WIN32)
#define _CRTDBG_MAP_ALLOC
#endif

#if defined(WINSOCK2)
#	include <winsock2.h>
#	include <ws2tcpip.h>
#elif defined(WINSOCK1)
#	include <winsock.h>
#	include <wininet.h>
#endif

#include "ILibParsers.h"
#include "UPnPMicroStack.h"
#include "ILibWebServer.h"
#include "ILibWebClient.h"
#include "ILibAsyncSocket.h"

#if defined(WIN32)
#include <crtdbg.h>
#endif

#define UPNP_HTTP_MAXSOCKETS 5
#define UPNP_PORT 1900
#define UPNP_GROUP "239.255.255.250"
#define UPnPMIN(a,b) (((a)<(b))?(a):(b))

#define LVL3DEBUG(x)

UPnPMicroStackToken UPnPCreateMicroStack(void *Chain, const char* FriendlyName,const char* UDN, const char* SerialNumber, const int NotifyCycleSeconds, const unsigned short PortNum);
/* UPnP Set Function Pointers Methods */
void (*UPnPFP_PresentationPage) (void* upnptoken,struct packetheader *packet);
/*! \var UPnPFP_ImportedService_getTcpServer
\brief Dispatch Pointer for ImportedService >> urn:schemas-upnp-org:service::1 >> getTcpServer
*/
void (*UPnPFP_ImportedService_getTcpServer) (void* upnptoken);
/*! \var UPnPFP_ImportedService_setForce
\brief Dispatch Pointer for ImportedService >> urn:schemas-upnp-org:service::1 >> setForce
*/
void (*UPnPFP_ImportedService_setForce) (void* upnptoken,int f);
/*! \var UPnPFP_ImportedService_setPage
\brief Dispatch Pointer for ImportedService >> urn:schemas-upnp-org:service::1 >> setPage
*/
void (*UPnPFP_ImportedService_setPage) (void* upnptoken,char* p);
/*! \var UPnPFP_ImportedService_setSerial
\brief Dispatch Pointer for ImportedService >> urn:schemas-upnp-org:service::1 >> setSerial
*/
void (*UPnPFP_ImportedService_setSerial) (void* upnptoken,char* s);
/*! \var UPnPFP_ImportedService_setX
\brief Dispatch Pointer for ImportedService >> urn:schemas-upnp-org:service::1 >> setX
*/
void (*UPnPFP_ImportedService_setX) (void* upnptoken,int x);
/*! \var UPnPFP_ImportedService_setY
\brief Dispatch Pointer for ImportedService >> urn:schemas-upnp-org:service::1 >> setY
*/
void (*UPnPFP_ImportedService_setY) (void* upnptoken,int y);



const int UPnPDeviceDescriptionTemplateLengthUX = 865;
const int UPnPDeviceDescriptionTemplateLength = 516;
const char UPnPDeviceDescriptionTemplate[516]={
	0x5A,0x3C,0x3F,0x78,0x6D,0x6C,0x20,0x76,0x65,0x72,0x73,0x69,0x6F,0x6E,0x3D,0x22,0x31,0x2E,0x30,0x22
	,0x20,0x65,0x6E,0x63,0x6F,0x64,0x69,0x6E,0x67,0x3D,0x22,0x75,0x74,0x66,0x2D,0x38,0x22,0x3F,0x3E,0x3C
	,0x72,0x6F,0x6F,0x74,0x20,0x78,0x6D,0x6C,0x6E,0x73,0x3D,0x22,0x75,0x72,0x6E,0x3A,0x73,0x63,0x68,0x65
	,0x6D,0x61,0x73,0x2D,0x75,0x70,0x6E,0x70,0x2D,0x6F,0x72,0x67,0x3A,0x64,0x65,0x76,0x69,0x63,0x65,0x2D
	,0x31,0x2D,0x30,0x22,0x3E,0x3C,0x73,0x70,0x65,0x63,0x56,0xC6,0x14,0x0B,0x3E,0x3C,0x6D,0x61,0x6A,0x6F
	,0x72,0x3E,0x31,0x3C,0x2F,0x46,0x02,0x0A,0x3C,0x6D,0x69,0x6E,0x6F,0x72,0x3E,0x30,0x3C,0x2F,0x46,0x02
	,0x02,0x3C,0x2F,0x8D,0x0B,0x00,0x06,0x12,0x00,0x08,0x02,0x05,0x54,0x79,0x70,0x65,0x3E,0x1B,0x1C,0x0B
	,0x3A,0x53,0x61,0x6D,0x70,0x6C,0x65,0x3A,0x31,0x3C,0x2F,0x4B,0x0C,0x12,0x3C,0x66,0x72,0x69,0x65,0x6E
	,0x64,0x6C,0x79,0x4E,0x61,0x6D,0x65,0x3E,0x25,0x73,0x3C,0x2F,0x4D,0x04,0x21,0x3C,0x6D,0x61,0x6E,0x75
	,0x66,0x61,0x63,0x74,0x75,0x72,0x65,0x72,0x3E,0x49,0x6E,0x74,0x65,0x6C,0x20,0x43,0x6F,0x72,0x70,0x6F
	,0x72,0x61,0x74,0x69,0x6F,0x6E,0x3C,0x2F,0x0D,0x08,0x00,0x8D,0x0B,0x10,0x55,0x52,0x4C,0x3E,0x68,0x74
	,0x74,0x70,0x3A,0x2F,0x2F,0x77,0x77,0x77,0x2E,0x69,0x04,0x0F,0x06,0x2E,0x63,0x6F,0x6D,0x3C,0x2F,0x90
	,0x09,0x0D,0x3C,0x6D,0x6F,0x64,0x65,0x6C,0x44,0x65,0x73,0x63,0x72,0x69,0x70,0xC4,0x15,0x01,0x3E,0xC6
	,0x2A,0x07,0x20,0x55,0x50,0x6E,0x50,0x20,0x44,0x85,0x4B,0x15,0x20,0x55,0x73,0x69,0x6E,0x67,0x20,0x41
	,0x75,0x74,0x6F,0x2D,0x47,0x65,0x6E,0x65,0x72,0x61,0x74,0x65,0x64,0x46,0x08,0x07,0x53,0x74,0x61,0x63
	,0x6B,0x3C,0x2F,0x51,0x11,0x00,0xC6,0x15,0x00,0x05,0x36,0x00,0x07,0x14,0x00,0x8F,0x0F,0x00,0x86,0x16
	,0x02,0x3C,0x2F,0x0A,0x0A,0x00,0xC7,0x0C,0x0A,0x75,0x6D,0x62,0x65,0x72,0x3E,0x58,0x31,0x3C,0x2F,0x0C
	,0x04,0x06,0x3C,0x73,0x65,0x72,0x69,0x61,0x88,0x07,0x00,0xC4,0x4A,0x00,0x4D,0x04,0x0A,0x3C,0x55,0x44
	,0x4E,0x3E,0x75,0x75,0x69,0x64,0x3A,0x84,0x51,0x03,0x55,0x44,0x4E,0x45,0x0C,0x00,0x84,0x7A,0x04,0x4C
	,0x69,0x73,0x74,0x49,0x03,0x00,0x89,0x05,0x00,0x1A,0x6C,0x00,0xC7,0x0D,0x03,0x3A,0x3A,0x31,0xC5,0x18
	,0x00,0x0A,0x6B,0x00,0x07,0x14,0x02,0x49,0x64,0x05,0x7A,0x00,0x10,0x0C,0x05,0x49,0x64,0x3A,0x3C,0x2F
	,0xCA,0x08,0x05,0x3C,0x53,0x43,0x50,0x44,0x44,0x61,0x09,0x49,0x6D,0x70,0x6F,0x72,0x74,0x65,0x64,0x53
	,0x86,0x23,0x0B,0x2F,0x73,0x63,0x70,0x64,0x2E,0x78,0x6D,0x6C,0x3C,0x2F,0x88,0x08,0x08,0x3C,0x63,0x6F
	,0x6E,0x74,0x72,0x6F,0x6C,0x94,0x0B,0x00,0xC7,0x06,0x02,0x3C,0x2F,0x0B,0x09,0x09,0x3C,0x65,0x76,0x65
	,0x6E,0x74,0x53,0x75,0x62,0xD4,0x17,0x00,0x05,0x07,0x02,0x3C,0x2F,0xCC,0x08,0x00,0xC9,0x31,0x03,0x3E
	,0x3C,0x2F,0x0D,0x45,0x01,0x2F,0xC8,0xB0,0x01,0x2F,0x44,0xCD,0x01,0x3E,0x00,0x00};
/* ImportedService */
const int UPnPImportedServiceDescriptionLengthUX = 1947;
const int UPnPImportedServiceDescriptionLength = 620;
const char UPnPImportedServiceDescription[620] = {
	0x4E,0x48,0x54,0x54,0x50,0x2F,0x31,0x2E,0x30,0x20,0x32,0x30,0x30,0x20,0x20,0x4F,0x4B,0x0D,0x0A,0x43
	,0x4F,0x4E,0x54,0x45,0x4E,0x54,0x2D,0x54,0x59,0x50,0x45,0x3A,0x20,0x20,0x74,0x65,0x78,0x74,0x2F,0x78
	,0x6D,0x6C,0x3B,0x20,0x63,0x68,0x61,0x72,0x73,0x65,0x74,0x3D,0x22,0x75,0x74,0x66,0x2D,0x38,0x22,0x0D
	,0x0A,0x53,0x65,0x72,0x76,0x65,0x72,0x3A,0x20,0x50,0x4F,0x53,0x49,0x58,0x2C,0x20,0x55,0x50,0x6E,0xC5
	,0x12,0x12,0x2C,0x20,0x49,0x6E,0x74,0x65,0x6C,0x20,0x4D,0x69,0x63,0x72,0x6F,0x53,0x74,0x61,0x63,0x6B
	,0x44,0x18,0x3B,0x2E,0x31,0x38,0x36,0x38,0x0D,0x0A,0x43,0x6F,0x6E,0x74,0x65,0x6E,0x74,0x2D,0x4C,0x65
	,0x6E,0x67,0x74,0x68,0x3A,0x20,0x31,0x38,0x31,0x31,0x0D,0x0A,0x0D,0x0A,0x3C,0x3F,0x78,0x6D,0x6C,0x20
	,0x76,0x65,0x72,0x73,0x69,0x6F,0x6E,0x3D,0x22,0x31,0x2E,0x30,0x22,0x20,0x65,0x6E,0x63,0x6F,0x64,0x69
	,0x6E,0x67,0x88,0x1C,0x37,0x3F,0x3E,0x3C,0x73,0x63,0x70,0x64,0x20,0x78,0x6D,0x6C,0x6E,0x73,0x3D,0x22
	,0x75,0x72,0x6E,0x3A,0x73,0x63,0x68,0x65,0x6D,0x61,0x73,0x2D,0x75,0x70,0x6E,0x70,0x2D,0x6F,0x72,0x67
	,0x3A,0x73,0x65,0x72,0x76,0x69,0x63,0x65,0x2D,0x31,0x2D,0x30,0x22,0x3E,0x3C,0x73,0x70,0x65,0x63,0x56
	,0x06,0x15,0x0B,0x3E,0x3C,0x6D,0x61,0x6A,0x6F,0x72,0x3E,0x31,0x3C,0x2F,0x46,0x02,0x0A,0x3C,0x6D,0x69
	,0x6E,0x6F,0x72,0x3E,0x30,0x3C,0x2F,0x46,0x02,0x02,0x3C,0x2F,0x8D,0x0B,0x0A,0x61,0x63,0x74,0x69,0x6F
	,0x6E,0x4C,0x69,0x73,0x74,0x08,0x03,0x0D,0x3E,0x3C,0x6E,0x61,0x6D,0x65,0x3E,0x67,0x65,0x74,0x54,0x63
	,0x70,0x06,0x3F,0x02,0x3C,0x2F,0xC5,0x04,0x09,0x3C,0x61,0x72,0x67,0x75,0x6D,0x65,0x6E,0x74,0xC7,0x0B
	,0x00,0x87,0x03,0x00,0x47,0x0C,0x01,0x61,0x88,0x09,0x04,0x64,0x69,0x72,0x65,0x86,0x12,0x05,0x6F,0x75
	,0x74,0x3C,0x2F,0xCA,0x03,0x17,0x3C,0x72,0x65,0x6C,0x61,0x74,0x65,0x64,0x53,0x74,0x61,0x74,0x65,0x56
	,0x61,0x72,0x69,0x61,0x62,0x6C,0x65,0x3E,0x74,0x8A,0x19,0x00,0x15,0x08,0x02,0x3C,0x2F,0x4A,0x1A,0x01
	,0x2F,0x8E,0x20,0x04,0x2F,0x61,0x63,0x74,0x8B,0x31,0x00,0x87,0x2E,0x08,0x73,0x65,0x74,0x46,0x6F,0x72
	,0x63,0x65,0xA5,0x2D,0x01,0x66,0x92,0x2D,0x02,0x69,0x6E,0x62,0x2D,0x01,0x66,0x46,0x18,0x00,0x7F,0x2C
	,0x00,0x4A,0x2C,0x03,0x50,0x61,0x67,0x26,0x2C,0x01,0x70,0x36,0x2C,0x03,0x70,0x61,0x67,0xFF,0x2B,0x00
	,0x0D,0x58,0x06,0x53,0x65,0x72,0x69,0x61,0x6C,0xE5,0x85,0x01,0x73,0x76,0x58,0x01,0x73,0x87,0x18,0x00
	,0xFF,0x84,0x00,0xCA,0x84,0x01,0x58,0x65,0xB1,0x01,0x78,0xF6,0x83,0x01,0x78,0x3F,0xAF,0x00,0x0C,0xAF
	,0x01,0x59,0xA5,0xDB,0x01,0x79,0x36,0xAE,0x01,0x79,0x7B,0xD9,0x00,0x87,0xDB,0x00,0x46,0xFF,0x07,0x73
	,0x65,0x72,0x76,0x69,0x63,0x65,0xC5,0xF2,0x01,0x54,0x06,0xEA,0x01,0x73,0xCC,0xF5,0x11,0x20,0x73,0x65
	,0x6E,0x64,0x45,0x76,0x65,0x6E,0x74,0x73,0x3D,0x22,0x79,0x65,0x73,0x22,0x08,0xB0,0x00,0x4B,0xBA,0x11
	,0x64,0x61,0x74,0x61,0x54,0x79,0x70,0x65,0x3E,0x73,0x74,0x72,0x69,0x6E,0x67,0x3C,0x2F,0x49,0x04,0x03
	,0x3C,0x2F,0x73,0xCE,0xD4,0x00,0x25,0x17,0x01,0x78,0x51,0x16,0x02,0x69,0x34,0x7F,0x15,0x03,0x65,0x3E
	,0x79,0x7F,0x15,0x00,0x8A,0x41,0x02,0x6E,0x6F,0x48,0x41,0x09,0x74,0x63,0x70,0x53,0x65,0x72,0x76,0x65
	,0x72,0xBF,0x42,0x00,0x99,0x59,0x01,0x73,0x0D,0xE8,0x00,0x3F,0x5A,0x00,0x11,0x71,0x05,0x66,0x6F,0x72
	,0x63,0x65,0x2F,0x5B,0x01,0x2F,0x53,0x8C,0x03,0x2F,0x73,0x63,0x00,0x00,0x03,0x70,0x64,0x3E,0x00,0x00
};



struct UPnPDataObject;

//
// It should not be necessary to expose/modify any of these structures. They
// are used by the internal stack
//

struct SubscriberInfo
{
	char* SID;		// Subscription ID
	int SIDLength;
	int SEQ;
	
	
	int Address;
	unsigned short Port;
	char* Path;
	int PathLength;
	int RefCount;
	int Disposing;
	
	#if defined(WIN32) || defined(_WIN32_WCE)
	unsigned int RenewByTime;
	#else
	struct timeval RenewByTime;
	#endif
	
	struct SubscriberInfo *Next;
	struct SubscriberInfo *Previous;
};
struct UPnPDataObject
{
	//
	// Absolutely DO NOT put anything above these 3 function pointers
	//
	ILibChain_PreSelect PreSelect;
	ILibChain_PostSelect PostSelect;
	ILibChain_Destroy Destroy;
	
	void *EventClient;
	void *Chain;
	int UpdateFlag;
	
	/* Network Poll */
	unsigned int NetworkPollTime;
	
	int ForceExit;
	char *UUID;
	char *UDN;
	char *Serial;
	
	void *WebServerTimer;
	void *HTTPServer;
	
	char *DeviceDescription;
	int DeviceDescriptionLength;
	int InitialNotify;
	
	char* ImportedService_page;
	char* ImportedService_x;
	char* ImportedService_y;
	char* ImportedService_serial;
	char* ImportedService_force;
	
	
	struct sockaddr_in addr;
	int addrlen;
	
	struct ip_mreq mreq;
	char message[4096];
	int *AddressList;
	int AddressListLength;
	
	int _NumEmbeddedDevices;
	int WebSocketPortNumber;
	
	
	
	#if defined(WIN32) || defined(_WIN32_WCE)
	SOCKET *NOTIFY_SEND_socks;
	SOCKET NOTIFY_RECEIVE_sock;
	SOCKET MSEARCH_sock;	
	unsigned int CurrentTime;
	unsigned int NotifyTime;
	#else
	int *NOTIFY_SEND_socks;
	int NOTIFY_RECEIVE_sock;
	int MSEARCH_sock;
	struct timeval CurrentTime;
	struct timeval NotifyTime;
	#endif
	
	int SID;
	int NotifyCycleTime;
	
	
	sem_t EventLock;
	struct SubscriberInfo *HeadSubscriberPtr_ImportedService;
	int NumberOfSubscribers_ImportedService;
	
};

struct MSEARCH_state
{
	char *ST;
	int STLength;
	void *upnp;
	struct sockaddr_in dest_addr;
};
struct UPnPFragmentNotifyStruct
{
	struct UPnPDataObject *upnp;
	int packetNumber;
};

/* Pre-declarations */
void UPnPFragmentedSendNotify(void *data);
void UPnPSendNotify(const struct UPnPDataObject *upnp);
void UPnPSendByeBye(const struct UPnPDataObject *upnp);
void UPnPMainInvokeSwitch();
void UPnPSendDataXmlEscaped(const void* UPnPToken, const char* Data, const int DataLength, const int Terminate);
void UPnPSendData(const void* UPnPToken, const char* Data, const int DataLength, const int Terminate);
int UPnPPeriodicNotify(struct UPnPDataObject *upnp);
void UPnPSendEvent_Body(void *upnptoken, char *body, int bodylength, struct SubscriberInfo *info);

/*! \fn UPnPGetWebServerToken(const UPnPMicroStackToken MicroStackToken)
\brief Converts a MicroStackToken to a WebServerToken
\para
\a MicroStackToken is the void* returned from a call to UPnPCreateMicroStack. The returned token, is the server token
not the session token.
\param MicroStackToken MicroStack Token
\returns WebServer Token
*/
void* UPnPGetWebServerToken(const UPnPMicroStackToken MicroStackToken)
{
	return(((struct UPnPDataObject*)MicroStackToken)->HTTPServer);
}


#define UPnPBuildSsdpResponsePacket(outpacket,outlength,ipaddr,port,EmbeddedDeviceNumber,USN,USNex,ST,NTex,NotifyTime)\
{\
	*outlength = sprintf(outpacket,"HTTP/1.1 200 OK\r\nLOCATION: http://%d.%d.%d.%d:%d/\r\nEXT:\r\nSERVER: %s, UPnP/1.0, Intel MicroStack/1.0.1868\r\nUSN: uuid:%s%s\r\nCACHE-CONTROL: max-age=%d\r\nST: %s%s\r\n\r\n" ,(ipaddr&0xFF),((ipaddr>>8)&0xFF),((ipaddr>>16)&0xFF),((ipaddr>>24)&0xFF),port,UPnPPLATFORM,USN,USNex,NotifyTime,ST,NTex);\
}
#define UPnPBuildSsdpNotifyPacket(outpacket,outlength,ipaddr,port,EmbeddedDeviceNumber,USN,USNex,NT,NTex,NotifyTime)\
{\
	*outlength = sprintf(outpacket,"NOTIFY * HTTP/1.1\r\nLOCATION: http://%d.%d.%d.%d:%d/\r\nHOST: 239.255.255.250:1900\r\nSERVER: %s, UPnP/1.0, Intel MicroStack/1.0.1868\r\nNTS: ssdp:alive\r\nUSN: uuid:%s%s\r\nCACHE-CONTROL: max-age=%d\r\nNT: %s%s\r\n\r\n",(ipaddr&0xFF),((ipaddr>>8)&0xFF),((ipaddr>>16)&0xFF),((ipaddr>>24)&0xFF),port,UPnPPLATFORM,USN,USNex,NotifyTime,NT,NTex);\
}




void UPnPSetDisconnectFlag(UPnPSessionToken token,void *flag)
{
	((struct ILibWebServer_Session*)token)->Reserved10=flag;
}


/*! \fn UPnPIPAddressListChanged(UPnPMicroStackToken MicroStackToken)
\brief Tell the underlying MicroStack that an IPAddress may have changed
\param MicroStackToken Microstack
*/
void UPnPIPAddressListChanged(UPnPMicroStackToken MicroStackToken)
{
	((struct UPnPDataObject*)MicroStackToken)->UpdateFlag = 1;
	ILibForceUnBlockChain(((struct UPnPDataObject*)MicroStackToken)->Chain);
}

//
//	Internal underlying Initialization, that shouldn't be called explicitely
// 
// <param name="state">State object</param>
// <param name="NotifyCycleSeconds">Cycle duration</param>
// <param name="PortNumber">Port Number</param>
void UPnPInit(struct UPnPDataObject *state,const int NotifyCycleSeconds,const unsigned short PortNumber)
{
	int ra = 1;
	int i;
	struct sockaddr_in addr;
	struct ip_mreq mreq;
	unsigned char TTL = 4;
	
	/* Complete State Reset */
	memset(state,0,sizeof(struct UPnPDataObject));
	
	/* Setup Notification Timer */
	state->NotifyCycleTime = NotifyCycleSeconds;
	
	#if defined(WIN32) || defined(_WIN32_WCE)
	state->CurrentTime = GetTickCount() / 1000;
	state->NotifyTime = state->CurrentTime  + (state->NotifyCycleTime/2);
	#else
	gettimeofday(&(state->CurrentTime),NULL);
	(state->NotifyTime).tv_sec = (state->CurrentTime).tv_sec  + (state->NotifyCycleTime/2);
	#endif
	
	memset((char *)&(state->addr), 0, sizeof(state->addr));
	state->addr.sin_family = AF_INET;
	state->addr.sin_addr.s_addr = htonl(INADDR_ANY);
	state->addr.sin_port = (unsigned short)htons(UPNP_PORT);
	state->addrlen = sizeof(state->addr);
	
	
	/* Set up socket */
	state->AddressListLength = ILibGetLocalIPAddressList(&(state->AddressList));
	
	#if defined(WIN32) || defined(_WIN32_WCE)
	state->NOTIFY_SEND_socks = (SOCKET*)malloc(sizeof(int)*(state->AddressListLength));
	#else
	state->NOTIFY_SEND_socks = (int*)malloc(sizeof(int)*(state->AddressListLength));
	#endif
	
	state->NOTIFY_RECEIVE_sock = socket(AF_INET, SOCK_DGRAM, 0);
	memset((char *)&(addr), 0, sizeof(addr));
	addr.sin_family = AF_INET;
	addr.sin_addr.s_addr = htonl(INADDR_ANY);
	addr.sin_port = (unsigned short)htons(UPNP_PORT);
	if (setsockopt(state->NOTIFY_RECEIVE_sock, SOL_SOCKET, SO_REUSEADDR,(char*)&ra, sizeof(ra)) < 0)
	{
		printf("Setting SockOpt SO_REUSEADDR failed\r\n");
		exit(1);
	}
	if (bind(state->NOTIFY_RECEIVE_sock, (struct sockaddr *) &(addr), sizeof(addr)) < 0)
	{
		printf("Could not bind to UPnP Listen Port\r\n");
		exit(1);
	}
	
	//
	// Iterate through all the current IP Addresses
	//
	for(i=0;i<state->AddressListLength;++i)
	{
		state->NOTIFY_SEND_socks[i] = socket(AF_INET, SOCK_DGRAM, 0);
		memset((char *)&(addr), 0, sizeof(addr));
		addr.sin_family = AF_INET;
		addr.sin_addr.s_addr = state->AddressList[i];
		addr.sin_port = (unsigned short)htons(UPNP_PORT);
		//
		// Set re-use address
		//
		if (setsockopt(state->NOTIFY_SEND_socks[i], SOL_SOCKET, SO_REUSEADDR,(char*)&ra, sizeof(ra)) == 0)
		{
			//
			// Set the Multicast TTL
			//
			if (setsockopt(state->NOTIFY_SEND_socks[i], IPPROTO_IP, IP_MULTICAST_TTL,(char*)&TTL, sizeof(TTL)) < 0)
			{
				/* Ignore this case */
			}
			
			//
			// Bind the socket
			//
			if (bind(state->NOTIFY_SEND_socks[i], (struct sockaddr *) &(addr), sizeof(addr)) == 0)
			{
				mreq.imr_multiaddr.s_addr = inet_addr(UPNP_GROUP);
				mreq.imr_interface.s_addr = state->AddressList[i];
				//
				// Join the multicast group
				//
				if (setsockopt(state->NOTIFY_RECEIVE_sock, IPPROTO_IP, IP_ADD_MEMBERSHIP,(char*)&mreq, sizeof(mreq)) < 0)
				{
					/* Does not matter */
				}
			}
		}
	}
	
}
void UPnPPostMX_Destroy(void *object)
{
	struct MSEARCH_state *mss = (struct MSEARCH_state*)object;
	free(mss->ST);
	free(mss);
}
void UPnPPostMX_MSEARCH(void *object)
{
	struct MSEARCH_state *mss = (struct MSEARCH_state*)object;
	
	char *b = (char*)malloc(sizeof(char)*5000);
	int packetlength;
	struct sockaddr_in response_addr;
	int response_addrlen;
	#if defined(WIN32) || defined(_WIN32_WCE)
	SOCKET *response_socket;
	#else
	int *response_socket;
	#endif
	
	int cnt;
	int i;
	struct sockaddr_in dest_addr = mss->dest_addr;
	char *ST = mss->ST;
	int STLength = mss->STLength;
	struct UPnPDataObject *upnp = (struct UPnPDataObject*)mss->upnp;
	
	#if defined(WIN32) || defined(_WIN32_WCE)
	response_socket = (SOCKET*)malloc(upnp->AddressListLength*sizeof(int));
	#else
	response_socket = (int*)malloc(upnp->AddressListLength*sizeof(int));
	#endif
	
	//
	// Iterate through all the current IP Addresses
	//
	for(i=0;i<upnp->AddressListLength;++i)
	{
		//
		// Create a socket to respond with
		//
		response_socket[i] = socket(AF_INET, SOCK_DGRAM, 0);
		if (response_socket[i]< 0)
		{
			printf("response socket");
			exit(1);
		}
		memset((char *)&(response_addr), 0, sizeof(response_addr));
		response_addr.sin_family = AF_INET;
		response_addr.sin_addr.s_addr = upnp->AddressList[i];
		response_addr.sin_port = (unsigned short)htons(0);
		response_addrlen = sizeof(response_addr);	
		if (bind(response_socket[i], (struct sockaddr *) &(response_addr), sizeof(response_addr)) < 0)
		{
			/* Ignore if this happens */
		}
	}
	
	//
	// Search for root device
	//
	if(STLength==15 && memcmp(ST,"upnp:rootdevice",15)==0)
	{
		for(i=0;i<upnp->AddressListLength;++i)
		{
			
			UPnPBuildSsdpResponsePacket(b,&packetlength,upnp->AddressList[i],(unsigned short)upnp->WebSocketPortNumber,0,upnp->UDN,"::upnp:rootdevice","upnp:rootdevice","",upnp->NotifyCycleTime);
			
			
			cnt = sendto(response_socket[i], b, packetlength, 0,(struct sockaddr *) &dest_addr, sizeof(dest_addr));
		}
	}
	//
	// Search for everything
	//
	else if(STLength==8 && memcmp(ST,"ssdp:all",8)==0)
	{
		for(i=0;i<upnp->AddressListLength;++i)
		{
			UPnPBuildSsdpResponsePacket(b,&packetlength,upnp->AddressList[i],(unsigned short)upnp->WebSocketPortNumber,0,upnp->UDN,"::upnp:rootdevice","upnp:rootdevice","",upnp->NotifyCycleTime);
			cnt = sendto(response_socket[i], b, packetlength, 0,
			(struct sockaddr *) &dest_addr, sizeof(dest_addr));
			UPnPBuildSsdpResponsePacket(b,&packetlength,upnp->AddressList[i],(unsigned short)upnp->WebSocketPortNumber,0,upnp->UDN,"",upnp->UUID,"",upnp->NotifyCycleTime);
			cnt = sendto(response_socket[i], b, packetlength, 0,
			(struct sockaddr *) &dest_addr, sizeof(dest_addr));
			UPnPBuildSsdpResponsePacket(b,&packetlength,upnp->AddressList[i],(unsigned short)upnp->WebSocketPortNumber,0,upnp->UDN,"::urn:schemas-upnp-org:device:Sample:1","urn:schemas-upnp-org:device:Sample:1","",upnp->NotifyCycleTime);
			cnt = sendto(response_socket[i], b, packetlength, 0,
			(struct sockaddr *) &dest_addr, sizeof(dest_addr));
			UPnPBuildSsdpResponsePacket(b,&packetlength,upnp->AddressList[i],(unsigned short)upnp->WebSocketPortNumber,0,upnp->UDN,"::urn:schemas-upnp-org:service::1","urn:schemas-upnp-org:service::1","",upnp->NotifyCycleTime);
			cnt = sendto(response_socket[i], b, packetlength, 0,
			(struct sockaddr *) &dest_addr, sizeof(dest_addr));
		}
		
	}
	if(STLength==(int)strlen(upnp->UUID) && memcmp(ST,upnp->UUID,(int)strlen(upnp->UUID))==0)
	{
		for(i=0;i<upnp->AddressListLength;++i)
		{
			UPnPBuildSsdpResponsePacket(b,&packetlength,upnp->AddressList[i],(unsigned short)upnp->WebSocketPortNumber,0,upnp->UDN,"",upnp->UUID,"",upnp->NotifyCycleTime);
			cnt = sendto(response_socket[i], b, packetlength, 0,
			(struct sockaddr *) &dest_addr, sizeof(dest_addr));
		}
	}
	if(STLength>=35 && memcmp(ST,"urn:schemas-upnp-org:device:Sample:",35)==0 && atoi(ST+35)<=1)
	{
		for(i=0;i<upnp->AddressListLength;++i)
		{
			UPnPBuildSsdpResponsePacket(b,&packetlength,upnp->AddressList[i],(unsigned short)upnp->WebSocketPortNumber,0,upnp->UDN,"::urn:schemas-upnp-org:device:Sample:1",ST,"",upnp->NotifyCycleTime);
			cnt = sendto(response_socket[i], b, packetlength, 0,
			(struct sockaddr *) &dest_addr, sizeof(dest_addr));
		}
	}
	if(STLength>=30 && memcmp(ST,"urn:schemas-upnp-org:service::",30)==0 && atoi(ST+30)<=1)
	{
		for(i=0;i<upnp->AddressListLength;++i)
		{
			UPnPBuildSsdpResponsePacket(b,&packetlength,upnp->AddressList[i],(unsigned short)upnp->WebSocketPortNumber,0,upnp->UDN,"::urn:schemas-upnp-org:service::1",ST,"",upnp->NotifyCycleTime);
			cnt = sendto(response_socket[i], b, packetlength, 0,
			(struct sockaddr *) &dest_addr, sizeof(dest_addr));
		}
	}
	
	
	for(i=0;i<upnp->AddressListLength;++i)
	{
		#if defined(WIN32) || defined(_WIN32_WCE)
		closesocket(response_socket[i]);
		#else
		close(response_socket[i]);
		#endif
	}
	free(response_socket);
	free(mss->ST);
	free(mss);
	free(b);
}
void UPnPProcessMSEARCH(struct UPnPDataObject *upnp, struct packetheader *packet)
{
	char* ST = NULL;
	int STLength = 0;
	struct packetheader_field_node *node;
	int MANOK = 0;
	unsigned long MXVal;
	int MXOK = 0;
	int MX;
	struct MSEARCH_state *mss = NULL;
	
	if(memcmp(packet->DirectiveObj,"*",1)==0)
	{
		if(memcmp(packet->Version,"1.1",3)==0)
		{
			node = packet->FirstField;
			while(node!=NULL)
			{
				if(node->FieldLength==2 && strncasecmp(node->Field,"ST",2)==0)
				{
					//
					// This is what is being searched for
					//
					ST = (char*)malloc(1+node->FieldDataLength);
					memcpy(ST,node->FieldData,node->FieldDataLength);
					ST[node->FieldDataLength] = 0;
					STLength = node->FieldDataLength;
				}
				else if(node->FieldLength==3 && strncasecmp(node->Field,"MAN",3)==0 && memcmp(node->FieldData,"\"ssdp:discover\"",15)==0)
				{
					//
					// This is a required header field
					// 
					MANOK = 1;
				}
				else if(node->FieldLength==2 && strncasecmp(node->Field,"MX",2)==0 && ILibGetULong(node->FieldData,node->FieldDataLength,&MXVal)==0)
				{
					//
					// If the timeout value specified is greater than 10 seconds, just force it
					// down to 10 seconds
					//
					MXOK = 1;
					MXVal = MXVal>10?10:MXVal;
				}
				node = node->NextField;
			}
			if(MANOK!=0 && MXOK!=0)
			{
				if(MXVal==0)
				{
					MX = 0;
				}
				else
				{
					//
					// The timeout value should be a random number between 0 and the 
					// specified value
					//
					MX = (int)(0 + ((unsigned short)rand() % MXVal));
				}
				mss = (struct MSEARCH_state*)malloc(sizeof(struct MSEARCH_state));
				mss->ST = ST;
				mss->STLength = STLength;
				mss->upnp = upnp;
				memset((char *)&(mss->dest_addr), 0, sizeof(mss->dest_addr));
				mss->dest_addr.sin_family = AF_INET;
				mss->dest_addr.sin_addr = packet->Source->sin_addr;
				mss->dest_addr.sin_port = packet->Source->sin_port;
				
				//
				// Register for a timed callback, so we can respond later
				//
				ILibLifeTime_Add(upnp->WebServerTimer,mss,MX,&UPnPPostMX_MSEARCH,&UPnPPostMX_Destroy);
			}
			else
			{
				free(ST);
			}
		}
	}
}
#define UPnPDispatch_ImportedService_getTcpServer(buffer,offset,bufferLength, session)\
{\
	UPnPFP_ImportedService_getTcpServer((void*)session);\
}

void UPnPDispatch_ImportedService_setForce(char *buffer, int offset, int bufferLength, struct ILibWebServer_Session *ReaderObject)
{
	long TempLong;
	int OK = 0;
	char *p_f = NULL;
	int p_fLength = 0;
	int _f = 0;
	struct ILibXMLNode *xnode = ILibParseXML(buffer,offset,bufferLength);
	struct ILibXMLNode *root = xnode;
	if(ILibProcessXMLNodeList(root)!=0)
	{
		/* The XML is not well formed! */
		ILibDestructXMLNodeList(root);
		UPnPResponse_Error(ReaderObject,501,"Invalid XML");
		return;
	}
	while(xnode!=NULL)
	{
		if(xnode->StartTag!=0 && xnode->NameLength==8 && memcmp(xnode->Name,"Envelope",8)==0)
		{
			// Envelope
			xnode = xnode->Next;
			while(xnode!=NULL)
			{
				if(xnode->StartTag!=0 && xnode->NameLength==4 && memcmp(xnode->Name,"Body",4)==0)
				{
					// Body
					xnode = xnode->Next;
					while(xnode!=NULL)
					{
						if(xnode->StartTag!=0 && xnode->NameLength==8 && memcmp(xnode->Name,"setForce",8)==0)
						{
							// Inside the interesting part of the SOAP
							xnode = xnode->Next;
							while(xnode!=NULL)
							{
								if(xnode->NameLength==1 && memcmp(xnode->Name,"f",1)==0)
								{
									p_fLength = ILibReadInnerXML(xnode,&p_f);
									OK |= 1;
								}
								if(xnode->Peer==NULL)
								{
									xnode = xnode->Parent;
									break;
								}
								else
								{
									xnode = xnode->Peer;
								}
							}
						}
						if(xnode->Peer==NULL)
						{
							xnode = xnode->Parent;
							break;
						}
						else
						{
							xnode = xnode->Peer;
						}
					}
				}
				if(xnode->Peer==NULL)
				{
					xnode = xnode->Parent;
					break;
				}
				else
				{
					xnode = xnode->Peer;
				}
			}
		}
		xnode = xnode->Peer;
	}
	ILibDestructXMLNodeList(root);
	if (OK != 1)
	{
		UPnPResponse_Error(ReaderObject,402,"Incorrect Arguments");
		return;
	}
	
	/* Type Checking */
	OK = ILibGetLong(p_f,p_fLength, &TempLong);
	if(OK!=0)
	{
		UPnPResponse_Error(ReaderObject,402,"Argument[f] illegal value");
		return;
	}
	_f = (int)TempLong;
	UPnPFP_ImportedService_setForce((void*)ReaderObject,_f);
}

void UPnPDispatch_ImportedService_setPage(char *buffer, int offset, int bufferLength, struct ILibWebServer_Session *ReaderObject)
{
	int OK = 0;
	char *p_p = NULL;
	int p_pLength = 0;
	char* _p = "";
	int _pLength;
	struct ILibXMLNode *xnode = ILibParseXML(buffer,offset,bufferLength);
	struct ILibXMLNode *root = xnode;
	if(ILibProcessXMLNodeList(root)!=0)
	{
		/* The XML is not well formed! */
		ILibDestructXMLNodeList(root);
		UPnPResponse_Error(ReaderObject,501,"Invalid XML");
		return;
	}
	while(xnode!=NULL)
	{
		if(xnode->StartTag!=0 && xnode->NameLength==8 && memcmp(xnode->Name,"Envelope",8)==0)
		{
			// Envelope
			xnode = xnode->Next;
			while(xnode!=NULL)
			{
				if(xnode->StartTag!=0 && xnode->NameLength==4 && memcmp(xnode->Name,"Body",4)==0)
				{
					// Body
					xnode = xnode->Next;
					while(xnode!=NULL)
					{
						if(xnode->StartTag!=0 && xnode->NameLength==7 && memcmp(xnode->Name,"setPage",7)==0)
						{
							// Inside the interesting part of the SOAP
							xnode = xnode->Next;
							while(xnode!=NULL)
							{
								if(xnode->NameLength==1 && memcmp(xnode->Name,"p",1)==0)
								{
									p_pLength = ILibReadInnerXML(xnode,&p_p);
									p_p[p_pLength]=0;
									OK |= 1;
								}
								if(xnode->Peer==NULL)
								{
									xnode = xnode->Parent;
									break;
								}
								else
								{
									xnode = xnode->Peer;
								}
							}
						}
						if(xnode->Peer==NULL)
						{
							xnode = xnode->Parent;
							break;
						}
						else
						{
							xnode = xnode->Peer;
						}
					}
				}
				if(xnode->Peer==NULL)
				{
					xnode = xnode->Parent;
					break;
				}
				else
				{
					xnode = xnode->Peer;
				}
			}
		}
		xnode = xnode->Peer;
	}
	ILibDestructXMLNodeList(root);
	if (OK != 1)
	{
		UPnPResponse_Error(ReaderObject,402,"Incorrect Arguments");
		return;
	}
	
	/* Type Checking */
	_pLength = ILibInPlaceXmlUnEscape(p_p);
	_p = p_p;
	UPnPFP_ImportedService_setPage((void*)ReaderObject,_p);
}

void UPnPDispatch_ImportedService_setSerial(char *buffer, int offset, int bufferLength, struct ILibWebServer_Session *ReaderObject)
{
	int OK = 0;
	char *p_s = NULL;
	int p_sLength = 0;
	char* _s = "";
	int _sLength;
	struct ILibXMLNode *xnode = ILibParseXML(buffer,offset,bufferLength);
	struct ILibXMLNode *root = xnode;
	if(ILibProcessXMLNodeList(root)!=0)
	{
		/* The XML is not well formed! */
		ILibDestructXMLNodeList(root);
		UPnPResponse_Error(ReaderObject,501,"Invalid XML");
		return;
	}
	while(xnode!=NULL)
	{
		if(xnode->StartTag!=0 && xnode->NameLength==8 && memcmp(xnode->Name,"Envelope",8)==0)
		{
			// Envelope
			xnode = xnode->Next;
			while(xnode!=NULL)
			{
				if(xnode->StartTag!=0 && xnode->NameLength==4 && memcmp(xnode->Name,"Body",4)==0)
				{
					// Body
					xnode = xnode->Next;
					while(xnode!=NULL)
					{
						if(xnode->StartTag!=0 && xnode->NameLength==9 && memcmp(xnode->Name,"setSerial",9)==0)
						{
							// Inside the interesting part of the SOAP
							xnode = xnode->Next;
							while(xnode!=NULL)
							{
								if(xnode->NameLength==1 && memcmp(xnode->Name,"s",1)==0)
								{
									p_sLength = ILibReadInnerXML(xnode,&p_s);
									p_s[p_sLength]=0;
									OK |= 1;
								}
								if(xnode->Peer==NULL)
								{
									xnode = xnode->Parent;
									break;
								}
								else
								{
									xnode = xnode->Peer;
								}
							}
						}
						if(xnode->Peer==NULL)
						{
							xnode = xnode->Parent;
							break;
						}
						else
						{
							xnode = xnode->Peer;
						}
					}
				}
				if(xnode->Peer==NULL)
				{
					xnode = xnode->Parent;
					break;
				}
				else
				{
					xnode = xnode->Peer;
				}
			}
		}
		xnode = xnode->Peer;
	}
	ILibDestructXMLNodeList(root);
	if (OK != 1)
	{
		UPnPResponse_Error(ReaderObject,402,"Incorrect Arguments");
		return;
	}
	
	/* Type Checking */
	_sLength = ILibInPlaceXmlUnEscape(p_s);
	_s = p_s;
	UPnPFP_ImportedService_setSerial((void*)ReaderObject,_s);
}

void UPnPDispatch_ImportedService_setX(char *buffer, int offset, int bufferLength, struct ILibWebServer_Session *ReaderObject)
{
	long TempLong;
	int OK = 0;
	char *p_x = NULL;
	int p_xLength = 0;
	int _x = 0;
	struct ILibXMLNode *xnode = ILibParseXML(buffer,offset,bufferLength);
	struct ILibXMLNode *root = xnode;
	if(ILibProcessXMLNodeList(root)!=0)
	{
		/* The XML is not well formed! */
		ILibDestructXMLNodeList(root);
		UPnPResponse_Error(ReaderObject,501,"Invalid XML");
		return;
	}
	while(xnode!=NULL)
	{
		if(xnode->StartTag!=0 && xnode->NameLength==8 && memcmp(xnode->Name,"Envelope",8)==0)
		{
			// Envelope
			xnode = xnode->Next;
			while(xnode!=NULL)
			{
				if(xnode->StartTag!=0 && xnode->NameLength==4 && memcmp(xnode->Name,"Body",4)==0)
				{
					// Body
					xnode = xnode->Next;
					while(xnode!=NULL)
					{
						if(xnode->StartTag!=0 && xnode->NameLength==4 && memcmp(xnode->Name,"setX",4)==0)
						{
							// Inside the interesting part of the SOAP
							xnode = xnode->Next;
							while(xnode!=NULL)
							{
								if(xnode->NameLength==1 && memcmp(xnode->Name,"x",1)==0)
								{
									p_xLength = ILibReadInnerXML(xnode,&p_x);
									OK |= 1;
								}
								if(xnode->Peer==NULL)
								{
									xnode = xnode->Parent;
									break;
								}
								else
								{
									xnode = xnode->Peer;
								}
							}
						}
						if(xnode->Peer==NULL)
						{
							xnode = xnode->Parent;
							break;
						}
						else
						{
							xnode = xnode->Peer;
						}
					}
				}
				if(xnode->Peer==NULL)
				{
					xnode = xnode->Parent;
					break;
				}
				else
				{
					xnode = xnode->Peer;
				}
			}
		}
		xnode = xnode->Peer;
	}
	ILibDestructXMLNodeList(root);
	if (OK != 1)
	{
		UPnPResponse_Error(ReaderObject,402,"Incorrect Arguments");
		return;
	}
	
	/* Type Checking */
	OK = ILibGetLong(p_x,p_xLength, &TempLong);
	if(OK!=0)
	{
		UPnPResponse_Error(ReaderObject,402,"Argument[x] illegal value");
		return;
	}
	_x = (int)TempLong;
	UPnPFP_ImportedService_setX((void*)ReaderObject,_x);
}

void UPnPDispatch_ImportedService_setY(char *buffer, int offset, int bufferLength, struct ILibWebServer_Session *ReaderObject)
{
	long TempLong;
	int OK = 0;
	char *p_y = NULL;
	int p_yLength = 0;
	int _y = 0;
	struct ILibXMLNode *xnode = ILibParseXML(buffer,offset,bufferLength);
	struct ILibXMLNode *root = xnode;
	if(ILibProcessXMLNodeList(root)!=0)
	{
		/* The XML is not well formed! */
		ILibDestructXMLNodeList(root);
		UPnPResponse_Error(ReaderObject,501,"Invalid XML");
		return;
	}
	while(xnode!=NULL)
	{
		if(xnode->StartTag!=0 && xnode->NameLength==8 && memcmp(xnode->Name,"Envelope",8)==0)
		{
			// Envelope
			xnode = xnode->Next;
			while(xnode!=NULL)
			{
				if(xnode->StartTag!=0 && xnode->NameLength==4 && memcmp(xnode->Name,"Body",4)==0)
				{
					// Body
					xnode = xnode->Next;
					while(xnode!=NULL)
					{
						if(xnode->StartTag!=0 && xnode->NameLength==4 && memcmp(xnode->Name,"setY",4)==0)
						{
							// Inside the interesting part of the SOAP
							xnode = xnode->Next;
							while(xnode!=NULL)
							{
								if(xnode->NameLength==1 && memcmp(xnode->Name,"y",1)==0)
								{
									p_yLength = ILibReadInnerXML(xnode,&p_y);
									OK |= 1;
								}
								if(xnode->Peer==NULL)
								{
									xnode = xnode->Parent;
									break;
								}
								else
								{
									xnode = xnode->Peer;
								}
							}
						}
						if(xnode->Peer==NULL)
						{
							xnode = xnode->Parent;
							break;
						}
						else
						{
							xnode = xnode->Peer;
						}
					}
				}
				if(xnode->Peer==NULL)
				{
					xnode = xnode->Parent;
					break;
				}
				else
				{
					xnode = xnode->Peer;
				}
			}
		}
		xnode = xnode->Peer;
	}
	ILibDestructXMLNodeList(root);
	if (OK != 1)
	{
		UPnPResponse_Error(ReaderObject,402,"Incorrect Arguments");
		return;
	}
	
	/* Type Checking */
	OK = ILibGetLong(p_y,p_yLength, &TempLong);
	if(OK!=0)
	{
		UPnPResponse_Error(ReaderObject,402,"Argument[y] illegal value");
		return;
	}
	_y = (int)TempLong;
	UPnPFP_ImportedService_setY((void*)ReaderObject,_y);
}


int UPnPProcessPOST(struct ILibWebServer_Session *session, struct packetheader* header, char *bodyBuffer, int offset, int bodyBufferLength)
{
	struct packetheader_field_node *f = header->FirstField;
	char* HOST;
	char* SOAPACTION = NULL;
	int SOAPACTIONLength = 0;
	struct parser_result *r,*r2;
	struct parser_result_field *prf;
	
	int RetVal = 0;
	
	//
	// Iterate through all the HTTP Headers
	//
	while(f!=NULL)
	{
		if(f->FieldLength==4 && strncasecmp(f->Field,"HOST",4)==0)
		{
			HOST = f->FieldData;
		}
		else if(f->FieldLength==10 && strncasecmp(f->Field,"SOAPACTION",10)==0)
		{
			r = ILibParseString(f->FieldData,0,f->FieldDataLength,"#",1);
			SOAPACTION = r->LastResult->data;
			SOAPACTIONLength = r->LastResult->datalength-1;
			ILibDestructParserResults(r);
		}
		else if(f->FieldLength==10 && strncasecmp(f->Field,"USER-AGENT",10)==0)
		{
			// Check UPnP version of the Control Point which invoked us
			r = ILibParseString(f->FieldData,0,f->FieldDataLength," ",1);
			prf = r->FirstResult;
			while(prf!=NULL)
			{
				if(prf->datalength>5 && memcmp(prf->data,"UPnP/",5)==0)
				{
					r2 = ILibParseString(prf->data+5,0,prf->datalength-5,".",1);
					r2->FirstResult->data[r2->FirstResult->datalength]=0;
					r2->LastResult->data[r2->LastResult->datalength]=0;
					if(atoi(r2->FirstResult->data)==1 && atoi(r2->LastResult->data)>0)
					{
						session->Reserved9=1;
					}
					ILibDestructParserResults(r2);
				}
				prf = prf->NextResult;
			}
			ILibDestructParserResults(r);
		}
		f = f->NextField;
	}
	
	if(header->DirectiveObjLength==24 && memcmp((header->DirectiveObj)+1,"ImportedService/control",23)==0)
	{
		if(SOAPACTIONLength==12 && memcmp(SOAPACTION,"getTcpServer",12)==0)
		{
			UPnPDispatch_ImportedService_getTcpServer(bodyBuffer, offset, bodyBufferLength, session);
		}
		else if(SOAPACTIONLength==8 && memcmp(SOAPACTION,"setForce",8)==0)
		{
			UPnPDispatch_ImportedService_setForce(bodyBuffer, offset, bodyBufferLength, session);
		}
		else if(SOAPACTIONLength==7 && memcmp(SOAPACTION,"setPage",7)==0)
		{
			UPnPDispatch_ImportedService_setPage(bodyBuffer, offset, bodyBufferLength, session);
		}
		else if(SOAPACTIONLength==9 && memcmp(SOAPACTION,"setSerial",9)==0)
		{
			UPnPDispatch_ImportedService_setSerial(bodyBuffer, offset, bodyBufferLength, session);
		}
		else if(SOAPACTIONLength==4 && memcmp(SOAPACTION,"setX",4)==0)
		{
			UPnPDispatch_ImportedService_setX(bodyBuffer, offset, bodyBufferLength, session);
		}
		else if(SOAPACTIONLength==4 && memcmp(SOAPACTION,"setY",4)==0)
		{
			UPnPDispatch_ImportedService_setY(bodyBuffer, offset, bodyBufferLength, session);
		}
		else
		{
			RetVal=1;
		}
	}
	else
	{
		RetVal=1;
	}
	
	
	return(RetVal);
}
struct SubscriberInfo* UPnPRemoveSubscriberInfo(struct SubscriberInfo **Head, int *TotalSubscribers,char* SID, int SIDLength)
{
	struct SubscriberInfo *info = *Head;
	while(info!=NULL)
	{
		if(info->SIDLength==SIDLength && memcmp(info->SID,SID,SIDLength)==0)
		{
			if ( info->Previous )
			info->Previous->Next = info->Next;
			else
			*Head = info->Next;
			if ( info->Next )
			info->Next->Previous = info->Previous;
			break;
		}
		info = info->Next;
		
	}
	if(info!=NULL)
	{
		info->Previous = NULL;
		info->Next = NULL;
		--(*TotalSubscribers);
	}
	return(info);
}

#define UPnPDestructSubscriberInfo(info)\
{\
	free(info->Path);\
	free(info->SID);\
	free(info);\
}

#define UPnPDestructEventObject(EvObject)\
{\
	free(EvObject->PacketBody);\
	free(EvObject);\
}

#define UPnPDestructEventDataObject(EvData)\
{\
	free(EvData);\
}
void UPnPExpireSubscriberInfo(struct UPnPDataObject *d, struct SubscriberInfo *info)
{
	struct SubscriberInfo *t = info;
	while(t->Previous!=NULL)
	{
		t = t->Previous;
	}
	if(d->HeadSubscriberPtr_ImportedService==t)
	{
		--(d->NumberOfSubscribers_ImportedService);
	}
	
	
	if(info->Previous!=NULL)
	{
		// This is not the Head
		info->Previous->Next = info->Next;
		if(info->Next!=NULL)
		{
			info->Next->Previous = info->Previous;
		}
	}
	else
	{
		// This is the Head
		if(d->HeadSubscriberPtr_ImportedService==info)
		{
			d->HeadSubscriberPtr_ImportedService = info->Next;
			if(info->Next!=NULL)
			{
				info->Next->Previous = NULL;
			}
		}
		else 
		{
			// Error
			return;
		}
		
	}
	--info->RefCount;
	if(info->RefCount==0)
	{
		UPnPDestructSubscriberInfo(info);
	}
}

int UPnPSubscriptionExpired(struct SubscriberInfo *info)
{
	int RetVal = 0;
	#if defined(WIN32) || defined(_WIN32_WCE)
	if(info->RenewByTime < GetTickCount()/1000) {RetVal = -1;}
	#else
	struct timeval tv;
	gettimeofday(&tv,NULL);
	if((info->RenewByTime).tv_sec < tv.tv_sec) {RetVal = -1;}
	#endif
	return(RetVal);
}

void UPnPGetInitialEventBody_ImportedService(struct UPnPDataObject *UPnPObject,char ** body, int *bodylength)
{
	int TempLength;
	TempLength = (int)(167+(int)strlen(UPnPObject->ImportedService_page)+(int)strlen(UPnPObject->ImportedService_x)+(int)strlen(UPnPObject->ImportedService_y)+(int)strlen(UPnPObject->ImportedService_serial)+(int)strlen(UPnPObject->ImportedService_force));
	*body = (char*)malloc(sizeof(char)*TempLength);
	*bodylength = sprintf(*body,"page>%s</page></e:property><e:property><x>%s</x></e:property><e:property><y>%s</y></e:property><e:property><serial>%s</serial></e:property><e:property><force>%s</force",UPnPObject->ImportedService_page,UPnPObject->ImportedService_x,UPnPObject->ImportedService_y,UPnPObject->ImportedService_serial,UPnPObject->ImportedService_force);
}


void UPnPProcessUNSUBSCRIBE(struct packetheader *header, struct ILibWebServer_Session *session)
{
	char* SID = NULL;
	int SIDLength = 0;
	struct SubscriberInfo *Info;
	struct packetheader_field_node *f;
	char* packet = (char*)malloc(sizeof(char)*50);
	int packetlength;
	
	//
	// Iterate through all the HTTP headers
	//
	f = header->FirstField;
	while(f!=NULL)
	{
		if(f->FieldLength==3)
		{
			if(strncasecmp(f->Field,"SID",3)==0)
			{
				//
				// Get the Subscription ID
				//
				SID = f->FieldData;
				SIDLength = f->FieldDataLength;
			}
		}
		f = f->NextField;
	}
	sem_wait(&(((struct UPnPDataObject*)session->User)->EventLock));
	if(header->DirectiveObjLength==22 && memcmp(header->DirectiveObj + 1,"ImportedService/event",21)==0)
	{
		Info = UPnPRemoveSubscriberInfo(&(((struct UPnPDataObject*)session->User)->HeadSubscriberPtr_ImportedService),&(((struct UPnPDataObject*)session->User)->NumberOfSubscribers_ImportedService),SID,SIDLength);
		if(Info!=NULL)
		{
			--Info->RefCount;
			if(Info->RefCount==0)
			{
				UPnPDestructSubscriberInfo(Info);
			}
			packetlength = sprintf(packet,"HTTP/1.0 %d %s\r\nContent-Length: 0\r\n\r\n",200,"OK");
			ILibWebServer_Send_Raw(session,packet,packetlength,0,1);
		}
		else
		{
			packetlength = sprintf(packet,"HTTP/1.0 %d %s\r\nContent-Length: 0\r\n\r\n",412,"Invalid SID");
			ILibWebServer_Send_Raw(session,packet,packetlength,0,1);
		}
	}
	
	sem_post(&(((struct UPnPDataObject*)session->User)->EventLock));
}
void UPnPTryToSubscribe(char* ServiceName, long Timeout, char* URL, int URLLength,struct ILibWebServer_Session *session)
{
	int *TotalSubscribers = NULL;
	struct SubscriberInfo **HeadPtr = NULL;
	struct SubscriberInfo *NewSubscriber,*TempSubscriber;
	int SIDNumber,rnumber;
	char *SID;
	char *TempString;
	int TempStringLength;
	char *TempString2;
	long TempLong;
	char *packet;
	int packetlength;
	char* path;
	
	char* escapedURI;
	int escapedURILength;
	
	char *packetbody = NULL;
	int packetbodyLength;
	
	struct parser_result *p;
	struct parser_result *p2;
	
	struct UPnPDataObject *dataObject = (struct UPnPDataObject*)session->User;
	
	if(strncmp(ServiceName,"ImportedService",15)==0)
	{
		TotalSubscribers = &(dataObject->NumberOfSubscribers_ImportedService);
		HeadPtr = &(dataObject->HeadSubscriberPtr_ImportedService);
	}
	
	
	if(*HeadPtr!=NULL)
	{
		NewSubscriber = *HeadPtr;
		while(NewSubscriber!=NULL)
		{
			if(UPnPSubscriptionExpired(NewSubscriber)!=0)
			{
				TempSubscriber = NewSubscriber->Next;
				NewSubscriber = UPnPRemoveSubscriberInfo(HeadPtr,TotalSubscribers,NewSubscriber->SID,NewSubscriber->SIDLength);
				UPnPDestructSubscriberInfo(NewSubscriber);
				NewSubscriber = TempSubscriber;
			}
			else
			{
				NewSubscriber = NewSubscriber->Next;
			}
		}
	}
	//
	// The Maximum number of subscribers can be bounded
	//
	if(*TotalSubscribers<10)
	{
		NewSubscriber = (struct SubscriberInfo*)malloc(sizeof(struct SubscriberInfo));
		memset(NewSubscriber,0,sizeof(struct SubscriberInfo));
		
		
		//
		// The SID must be globally unique, so lets generate it using
		// a bunch of random hex characters
		//
		SID = (char*)malloc(43);
		memset(SID,0,38);
		sprintf(SID,"uuid:");
		for(SIDNumber=5;SIDNumber<=12;++SIDNumber)
		{
			rnumber = rand()%16;
			sprintf(SID+SIDNumber,"%x",rnumber);
		}
		sprintf(SID+SIDNumber,"-");
		for(SIDNumber=14;SIDNumber<=17;++SIDNumber)
		{
			rnumber = rand()%16;
			sprintf(SID+SIDNumber,"%x",rnumber);
		}
		sprintf(SID+SIDNumber,"-");
		for(SIDNumber=19;SIDNumber<=22;++SIDNumber)
		{
			rnumber = rand()%16;
			sprintf(SID+SIDNumber,"%x",rnumber);
		}
		sprintf(SID+SIDNumber,"-");
		for(SIDNumber=24;SIDNumber<=27;++SIDNumber)
		{
			rnumber = rand()%16;
			sprintf(SID+SIDNumber,"%x",rnumber);
		}
		sprintf(SID+SIDNumber,"-");
		for(SIDNumber=29;SIDNumber<=40;++SIDNumber)
		{
			rnumber = rand()%16;
			sprintf(SID+SIDNumber,"%x",rnumber);
		}
		
		p = ILibParseString(URL,0,URLLength,"://",3);
		if(p->NumResults==1)
		{
			ILibWebServer_Send_Raw(session,"HTTP/1.1 412 Precondition Failed\r\nContent-Length: 0\r\n\r\n",55,1,1);
			ILibDestructParserResults(p);
			return;
		}
		TempString = p->LastResult->data;
		TempStringLength = p->LastResult->datalength;
		ILibDestructParserResults(p);
		p = ILibParseString(TempString,0,TempStringLength,"/",1);
		p2 = ILibParseString(p->FirstResult->data,0,p->FirstResult->datalength,":",1);
		TempString2 = (char*)malloc(1+sizeof(char)*p2->FirstResult->datalength);
		memcpy(TempString2,p2->FirstResult->data,p2->FirstResult->datalength);
		TempString2[p2->FirstResult->datalength] = '\0';
		NewSubscriber->Address = inet_addr(TempString2);
		if(p2->NumResults==1)
		{
			NewSubscriber->Port = 80;
			path = (char*)malloc(1+TempStringLength - p2->FirstResult->datalength -1);
			memcpy(path,TempString + p2->FirstResult->datalength,TempStringLength - p2->FirstResult->datalength -1);
			path[TempStringLength - p2->FirstResult->datalength - 1] = '\0';
			NewSubscriber->Path = path;
			NewSubscriber->PathLength = (int)strlen(path);
		}
		else
		{
			ILibGetLong(p2->LastResult->data,p2->LastResult->datalength,&TempLong);
			NewSubscriber->Port = (unsigned short)TempLong;
			if(TempStringLength==p->FirstResult->datalength)
			{
				path = (char*)malloc(2);
				memcpy(path,"/",1);
				path[1] = '\0';
			}
			else
			{
				path = (char*)malloc(1+TempStringLength - p->FirstResult->datalength -1);
				memcpy(path,TempString + p->FirstResult->datalength,TempStringLength - p->FirstResult->datalength -1);
				path[TempStringLength - p->FirstResult->datalength -1] = '\0';
			}
			NewSubscriber->Path = path;
			NewSubscriber->PathLength = (int)strlen(path);
		}
		ILibDestructParserResults(p);
		ILibDestructParserResults(p2);
		free(TempString2);
		
		
		escapedURI = (char*)malloc(ILibHTTPEscapeLength(NewSubscriber->Path));
		escapedURILength = ILibHTTPEscape(escapedURI,NewSubscriber->Path);
		
		free(NewSubscriber->Path);
		NewSubscriber->Path = escapedURI;
		NewSubscriber->PathLength = escapedURILength;
		
		
		NewSubscriber->RefCount = 1;
		NewSubscriber->Disposing = 0;
		NewSubscriber->Previous = NULL;
		NewSubscriber->SID = SID;
		NewSubscriber->SIDLength = (int)strlen(SID);
		NewSubscriber->SEQ = 0;
		
		//
		// Determine what the subscription renewal cycle is
		//
		#if defined(WIN32) || defined(_WIN32_WCE)
		NewSubscriber->RenewByTime = (GetTickCount() / 1000) + Timeout;
		#else
		gettimeofday(&(NewSubscriber->RenewByTime),NULL);
		(NewSubscriber->RenewByTime).tv_sec += (int)Timeout;
		#endif
		NewSubscriber->Next = *HeadPtr;
		if(*HeadPtr!=NULL) {(*HeadPtr)->Previous = NewSubscriber;}
		*HeadPtr = NewSubscriber;
		++(*TotalSubscribers);
		LVL3DEBUG(printf("\r\n\r\nSubscribed [%s] %d.%d.%d.%d:%d FOR %d Duration\r\n",NewSubscriber->SID,(NewSubscriber->Address)&0xFF,(NewSubscriber->Address>>8)&0xFF,(NewSubscriber->Address>>16)&0xFF,(NewSubscriber->Address>>24)&0xFF,NewSubscriber->Port,Timeout);)
		#if defined(WIN32) || defined(_WIN32_WCE)	
		LVL3DEBUG(printf("TIMESTAMP: %d <%d>\r\n\r\n",(NewSubscriber->RenewByTime)-Timeout,NewSubscriber);)
		#else
		LVL3DEBUG(printf("TIMESTAMP: %d <%d>\r\n\r\n",(NewSubscriber->RenewByTime).tv_sec-Timeout,NewSubscriber);)
		#endif
		packet = (char*)malloc(134 + (int)strlen(SID) + (int)strlen(UPnPPLATFORM) + 4);
		packetlength = sprintf(packet,"HTTP/1.0 200 OK\r\nSERVER: %s, UPnP/1.0, Intel MicroStack/1.0.1868\r\nSID: %s\r\nTIMEOUT: Second-%ld\r\nContent-Length: 0\r\n\r\n",UPnPPLATFORM,SID,Timeout);
		if(strcmp(ServiceName,"ImportedService")==0)
		{
			UPnPGetInitialEventBody_ImportedService(dataObject,&packetbody,&packetbodyLength);
		}
		
		if (packetbody != NULL)	    {
			ILibWebServer_Send_Raw(session,packet,packetlength,0,1);
			
			UPnPSendEvent_Body(dataObject,packetbody,packetbodyLength,NewSubscriber);
			free(packetbody);
		} 
	}
	else
	{
		/* Too many subscribers */
		ILibWebServer_Send_Raw(session,"HTTP/1.1 412 Too Many Subscribers\r\nContent-Length: 0\r\n\r\n",56,1,1);
	}
}
void UPnPSubscribeEvents(char* path,int pathlength,char* Timeout,int TimeoutLength,char* URL,int URLLength,struct ILibWebServer_Session* session)
{
	long TimeoutVal;
	char* buffer = (char*)malloc(1+sizeof(char)*pathlength);
	
	ILibGetLong(Timeout,TimeoutLength,&TimeoutVal);
	memcpy(buffer,path,pathlength);
	buffer[pathlength] = '\0';
	free(buffer);
	if(TimeoutVal>7200) {TimeoutVal=7200;}
	
	if(pathlength==22 && memcmp(path+1,"ImportedService/event",21)==0)
	{
		UPnPTryToSubscribe("ImportedService",TimeoutVal,URL,URLLength,session);
	}
	else
	{
		ILibWebServer_Send_Raw(session,"HTTP/1.1 412 Invalid Service Name\r\nContent-Length: 0\r\n\r\n",56,1,1);
	}
	
}
void UPnPRenewEvents(char* path,int pathlength,char *_SID,int SIDLength, char* Timeout, int TimeoutLength, struct ILibWebServer_Session *ReaderObject)
{
	struct SubscriberInfo *info = NULL;
	long TimeoutVal;
	#if !defined(WIN32) && !defined(_WIN32_WCE)
	struct timeval tv;
	#endif
	char* packet;
	int packetlength;
	char* SID = (char*)malloc(SIDLength+1);
	memcpy(SID,_SID,SIDLength);
	SID[SIDLength] ='\0';
	#if defined(WIN32) || defined(_WIN32_WCE)
	LVL3DEBUG(printf("\r\n\r\nTIMESTAMP: %d\r\n",GetTickCount()/1000);)
	#else
	LVL3DEBUG(gettimeofday(&tv,NULL);)
	LVL3DEBUG(printf("\r\n\r\nTIMESTAMP: %d\r\n",tv.tv_sec);)
	#endif
	LVL3DEBUG(printf("SUBSCRIBER [%s] attempting to Renew Events for %s Duration [",SID,Timeout);)
	
	if(pathlength==22 && memcmp(path+1,"ImportedService/event",21)==0)
	{
		info = ((struct UPnPDataObject*)ReaderObject->User)->HeadSubscriberPtr_ImportedService;
	}
	
	
	//
	// Find this SID in the subscriber list, and recalculate
	// the expiration timeout
	//
	while(info!=NULL && strcmp(info->SID,SID)!=0)
	{
		info = info->Next;
	}
	if(info!=NULL)
	{
		ILibGetLong(Timeout,TimeoutLength,&TimeoutVal);
		#if defined(WIN32) || defined(_WIN32_WCE)
		info->RenewByTime = TimeoutVal + (GetTickCount() / 1000);
		#else
		gettimeofday(&tv,NULL);
		(info->RenewByTime).tv_sec = tv.tv_sec + TimeoutVal;
		#endif
		packet = (char*)malloc(134 + (int)strlen(SID) + 4);
		packetlength = sprintf(packet,"HTTP/1.0 200 OK\r\nSERVER: %s, UPnP/1.0, Intel MicroStack/1.0.1868\r\nSID: %s\r\nTIMEOUT: Second-%ld\r\nContent-Length: 0\r\n\r\n",UPnPPLATFORM,SID,TimeoutVal);
		ILibWebServer_Send_Raw(ReaderObject,packet,packetlength,0,1);
		LVL3DEBUG(printf("OK] {%d} <%d>\r\n\r\n",TimeoutVal,info);)
	}
	else
	{
		LVL3DEBUG(printf("FAILED]\r\n\r\n");)
		ILibWebServer_Send_Raw(ReaderObject,"HTTP/1.0 412 Precondition Failed\r\nContent-Length: 0\r\n\r\n",55,1,1);
	}
	free(SID);
}
void UPnPProcessSUBSCRIBE(struct packetheader *header, struct ILibWebServer_Session *session)
{
	char* SID = NULL;
	int SIDLength = 0;
	char* Timeout = NULL;
	int TimeoutLength = 0;
	char* URL = NULL;
	int URLLength = 0;
	struct parser_result *p;
	
	struct packetheader_field_node *f;
	
	//
	// Iterate through all the HTTP Headers
	//
	f = header->FirstField;
	while(f!=NULL)
	{
		if(f->FieldLength==3 && strncasecmp(f->Field,"SID",3)==0)
		{
			//
			// Get the Subscription ID
			//
			SID = f->FieldData;
			SIDLength = f->FieldDataLength;
		}
		else if(f->FieldLength==8 && strncasecmp(f->Field,"Callback",8)==0)
		{
			//
			// Get the Callback URL
			//
			URL = f->FieldData;
			URLLength = f->FieldDataLength;
		}
		else if(f->FieldLength==7 && strncasecmp(f->Field,"Timeout",7)==0)
		{
			//
			// Get the requested timeout value
			//
			Timeout = f->FieldData;
			TimeoutLength = f->FieldDataLength;
		}
		
		f = f->NextField;
	}
	if(Timeout==NULL)
	{
		//
		// It a timeout wasn't specified, force it to a specific value
		//
		Timeout = "7200";
		TimeoutLength = 4;
	}
	else
	{
		p = ILibParseString(Timeout,0,TimeoutLength,"-",1);
		if(p->NumResults==2)
		{
			Timeout = p->LastResult->data;
			TimeoutLength = p->LastResult->datalength;
			if(TimeoutLength==8 && strncasecmp(Timeout,"INFINITE",8)==0)
			{
				//
				// Infinite timeouts will cause problems, so we don't allow it
				//
				Timeout = "7200";
				TimeoutLength = 4;
			}
		}
		else
		{
			Timeout = "7200";
			TimeoutLength = 4;
		}
		ILibDestructParserResults(p);
	}
	if(SID==NULL)
	{
		//
		// If not SID was specified, this is a subscription request
		//
		
		/* Subscribe */
		UPnPSubscribeEvents(header->DirectiveObj,header->DirectiveObjLength,Timeout,TimeoutLength,URL,URLLength,session);
	}
	else
	{
		//
		// If a SID was specified, it is a renewal request for an existing subscription
		//
		
		/* Renew */
		UPnPRenewEvents(header->DirectiveObj,header->DirectiveObjLength,SID,SIDLength,Timeout,TimeoutLength,session);
	}
}
void UPnPProcessHTTPPacket(struct ILibWebServer_Session *session, struct packetheader* header, char *bodyBuffer, int offset, int bodyBufferLength)

{
	struct UPnPDataObject *dataObject = (struct UPnPDataObject*)session->User;
	#if defined(WIN32) || defined(_WIN32_WCE)
	char *responseHeader = "\r\nCONTENT-TYPE:  text/xml; charset=\"utf-8\"\r\nServer: WINDOWS, UPnP/1.0, Intel MicroStack/1.0.1868";
	#else
	char *responseHeader = "\r\nCONTENT-TYPE:  text/xml; charset=\"utf-8\"\r\nServer: POSIX, UPnP/1.0, Intel MicroStack/1.0.1868";
	#endif
	char *errorTemplate = "HTTP/1.0 %d %s\r\nServer: %s, UPnP/1.0, Intel MicroStack/1.0.1868\r\nContent-Length: 0\r\n\r\n";
	char *errorPacket;
	int errorPacketLength;
	char *buffer;
	
	LVL3DEBUG(errorPacketLength=ILibGetRawPacket(header,&errorPacket);)
	LVL3DEBUG(printf("%s\r\n",errorPacket);)
	LVL3DEBUG(free(errorPacket);)			
	
	
	if(header->DirectiveLength==4 && memcmp(header->Directive,"HEAD",4)==0)
	{
		if(header->DirectiveObjLength==1 && memcmp(header->DirectiveObj,"/",1)==0)
		{
			//
			// A HEAD request for the device description document.
			// We stream the document back, so we don't return content length or anything
			// because the actual response won't have it either
			//
			ILibWebServer_StreamHeader_Raw(session,200,"OK",responseHeader,1);
			ILibWebServer_StreamBody(session,NULL,0,ILibAsyncSocket_MemoryOwnership_STATIC,1);
		}
		else if(header->DirectiveObjLength==25 && memcmp((header->DirectiveObj)+1,"ImportedService/scpd.xml",24)==0)
		{
			ILibWebServer_StreamHeader_Raw(session,200,"OK",responseHeader,1);
			ILibWebServer_StreamBody(session,NULL,0,ILibAsyncSocket_MemoryOwnership_STATIC,1);
		}
		
		else
		{
			//
			// A HEAD request for something we don't have
			//
			errorPacket = (char*)malloc(128);
			errorPacketLength = sprintf(errorPacket,errorTemplate,404,"File Not Found",UPnPPLATFORM);
			ILibWebServer_Send_Raw(session,errorPacket,errorPacketLength,0,1);
		}
	}
	else if(header->DirectiveLength==3 && memcmp(header->Directive,"GET",3)==0)
	{
		if(header->DirectiveObjLength==1 && memcmp(header->DirectiveObj,"/",1)==0)
		{
			//
			// A GET Request for the device description document, so lets stream
			// it back to the client
			//
			ILibWebServer_StreamHeader_Raw(session,200,"OK",responseHeader,1);
			ILibWebServer_StreamBody(session,dataObject->DeviceDescription,dataObject->DeviceDescriptionLength,1,1);
		}
		else if(header->DirectiveObjLength==25 && memcmp((header->DirectiveObj)+1,"ImportedService/scpd.xml",24)==0)
		{
			buffer = ILibDecompressString((char*)UPnPImportedServiceDescription,UPnPImportedServiceDescriptionLength,UPnPImportedServiceDescriptionLengthUX);
			ILibWebServer_Send_Raw(session,buffer,UPnPImportedServiceDescriptionLengthUX,0,1);
		}
		
		else
		{
			//
			// A GET Request for something we don't have
			//
			errorPacket = (char*)malloc(128);
			errorPacketLength = sprintf(errorPacket,errorTemplate,404,"File Not Found",UPnPPLATFORM);
			ILibWebServer_Send_Raw(session,errorPacket,errorPacketLength,0,1);
		}
	}
	else if(header->DirectiveLength==4 && memcmp(header->Directive,"POST",4)==0)
	{
		//
		// Defer Control to the POST Handler
		//
		if(UPnPProcessPOST(session,header,bodyBuffer,offset,bodyBufferLength)!=0)
		{
			//
			// A POST for an action that doesn't exist
			//
			UPnPResponse_Error(session,401,"Invalid Action");
		}
	}
	else if(header->DirectiveLength==9 && memcmp(header->Directive,"SUBSCRIBE",9)==0)
	{
		//
		// Subscription Handler
		//
		UPnPProcessSUBSCRIBE(header,session);
	}
	else if(header->DirectiveLength==11 && memcmp(header->Directive,"UNSUBSCRIBE",11)==0)
	{
		//
		// UnSubscribe Handler
		//
		UPnPProcessUNSUBSCRIBE(header,session);
	}
	else
	{
		//
		// The client tried something we didn't expect/support
		//
		errorPacket = (char*)malloc(128);
		errorPacketLength = sprintf(errorPacket,errorTemplate,400,"Bad Request",UPnPPLATFORM);
		ILibWebServer_Send_Raw(session,errorPacket,errorPacketLength,1,1);
	}
}
void UPnPFragmentedSendNotify_Destroy(void *data);
void UPnPMasterPreSelect(void* object,fd_set *socketset, fd_set *writeset, fd_set *errorset, int* blocktime)
{
	int i;
	struct UPnPDataObject *UPnPObject = (struct UPnPDataObject*)object;
	
	int ra = 1;
	struct sockaddr_in addr;
	struct ip_mreq mreq;
	unsigned char TTL = 4;
	struct UPnPFragmentNotifyStruct *f;
	int timeout;
	
	if(UPnPObject->InitialNotify==0)
	{
		//
		// The initial "HELLO" packets were not sent yet, so lets send them
		//
		UPnPObject->InitialNotify = -1;
		//
		// In case we were interrupted, we need to flush out the caches of
		// all the control points by sending a "byebye" first, to insure
		// control points don't ignore our "hello" packets thinking they are just
		// periodic re-advertisements.
		//
		UPnPSendByeBye(UPnPObject);
		
		//
		// Iterate through all the packet types
		//
		for(i=1;i<=4;++i)
		{
			f = (struct UPnPFragmentNotifyStruct*)malloc(sizeof(struct UPnPFragmentNotifyStruct));
			f->packetNumber=i;
			f->upnp = UPnPObject;
			//
			// We need to inject some delay in these packets to space them out,
			// otherwise we could overflow the inbound buffer of the recipient, causing them
			// to lose packets. And UPnP/1.0 control points are not as robust as UPnP/1.1 control points,
			// so they need all the help they can get ;)
			//
			timeout = (int)(0 + ((unsigned short)rand() % (500)));
			do
			{
				f->upnp->InitialNotify = rand();
			}while(f->upnp->InitialNotify==0);
			//
			// Register for the timed callback, to actually send the packet
			//
			ILibLifeTime_AddEx(f->upnp->WebServerTimer,f,timeout,&UPnPFragmentedSendNotify,&UPnPFragmentedSendNotify_Destroy);
		}
	}
	if(UPnPObject->UpdateFlag!=0)
	{
		//
		// Somebody told us that we should recheck our IP Address table,
		// as one of them may have changed
		//
		UPnPObject->UpdateFlag = 0;
		
		/* Clear Sockets */
		
		
		//
		// Iterate through all the currently bound IP addresses
		// and release the sockets
		//
		for(i=0;i<UPnPObject->AddressListLength;++i)
		{
			#if defined(WIN32) || defined(_WIN32_WCE)
			closesocket(UPnPObject->NOTIFY_SEND_socks[i]);
			#else
			close(UPnPObject->NOTIFY_SEND_socks[i]);
			#endif
		}
		free(UPnPObject->NOTIFY_SEND_socks);
		
		/* Set up socket */
		free(UPnPObject->AddressList);
		//
		// Fetch a current list of ip addresses
		//
		UPnPObject->AddressListLength = ILibGetLocalIPAddressList(&(UPnPObject->AddressList));
		#if defined(WIN32) || defined(_WIN32_WCE)	
		UPnPObject->NOTIFY_SEND_socks = (SOCKET*)malloc(sizeof(int)*(UPnPObject->AddressListLength));
		#else
		UPnPObject->NOTIFY_SEND_socks = (int*)malloc(sizeof(int)*(UPnPObject->AddressListLength));
		#endif
		
		//
		// Now that we have a new list of IP addresses, re-initialise everything
		//
		for(i=0;i<UPnPObject->AddressListLength;++i)
		{
			UPnPObject->NOTIFY_SEND_socks[i] = socket(AF_INET, SOCK_DGRAM, 0);
			memset((char *)&(addr), 0, sizeof(addr));
			addr.sin_family = AF_INET;
			addr.sin_addr.s_addr = UPnPObject->AddressList[i];
			addr.sin_port = (unsigned short)htons(UPNP_PORT);
			if (setsockopt(UPnPObject->NOTIFY_SEND_socks[i], SOL_SOCKET, SO_REUSEADDR,(char*)&ra, sizeof(ra)) == 0)
			{
				if (setsockopt(UPnPObject->NOTIFY_SEND_socks[i], IPPROTO_IP, IP_MULTICAST_TTL,(char*)&TTL, sizeof(TTL)) < 0)
				{
					// Ignore the case if setting the Multicast-TTL fails
				}
				if (bind(UPnPObject->NOTIFY_SEND_socks[i], (struct sockaddr *) &(addr), sizeof(addr)) == 0)
				{
					mreq.imr_multiaddr.s_addr = inet_addr(UPNP_GROUP);
					mreq.imr_interface.s_addr = UPnPObject->AddressList[i];
					if (setsockopt(UPnPObject->NOTIFY_RECEIVE_sock, IPPROTO_IP, IP_ADD_MEMBERSHIP,(char*)&mreq, sizeof(mreq)) < 0)
					{
						// Does not matter if it fails, just ignore
					}
				}
			}
		}
		
		//
		// Iterate through all the packet types, and re-broadcast
		//
		for(i=1;i<=4;++i)
		{
			f = (struct UPnPFragmentNotifyStruct*)malloc(sizeof(struct UPnPFragmentNotifyStruct));
			f->packetNumber=i;
			f->upnp = UPnPObject;
			//
			// Inject some random delay, to spread these packets out, to help prevent
			// the inbound buffer of the recipient from overflowing, causing dropped packets.
			//
			timeout = (int)(0 + ((unsigned short)rand() % (500)));
			ILibLifeTime_AddEx(f->upnp->WebServerTimer,f,timeout,&UPnPFragmentedSendNotify,&UPnPFragmentedSendNotify_Destroy);
		}
	}
	FD_SET(UPnPObject->NOTIFY_RECEIVE_sock,socketset);
	
}

void UPnPMasterPostSelect(void* object,int slct, fd_set *socketset, fd_set *writeset, fd_set *errorset)
{
	#if defined(WIN32) || defined(_WIN32_WCE)
	unsigned long flags=0;
	#endif
	int cnt = 0;
	
	struct packetheader *packet;
	struct UPnPDataObject *UPnPObject = (struct UPnPDataObject*)object;
	
	if(slct>0)
	{
		
		
		//
		// Check to see if we got any Multicast SEARCH requests
		//
		if(FD_ISSET(UPnPObject->NOTIFY_RECEIVE_sock,socketset)!=0)
		{	
			cnt = recvfrom(UPnPObject->NOTIFY_RECEIVE_sock, UPnPObject->message, sizeof(UPnPObject->message), 0,
			(struct sockaddr *) &(UPnPObject->addr), &(UPnPObject->addrlen));
			if (cnt < 0)
			{
				printf("recvfrom");
				exit(1);
			}
			else if (cnt == 0)
			{
				/* Socket Closed? */
			}
			packet = ILibParsePacketHeader(UPnPObject->message,0,cnt);
			if(packet!=NULL)
			{
				packet->Source = (struct sockaddr_in*)&(UPnPObject->addr);
				packet->ReceivingAddress = 0;
				if(packet->StatusCode==-1 && memcmp(packet->Directive,"M-SEARCH",8)==0)
				{
					//
					// Process the search request with our Multicast M-SEARCH Handler
					//
					UPnPProcessMSEARCH(UPnPObject, packet);
				}
				ILibDestructPacket(packet);
			}
		}
		
	}
}
void UPnPFragmentedSendNotify_Destroy(void *data)
{
	free(data);
}
void UPnPFragmentedSendNotify(void *data)
{
	struct UPnPFragmentNotifyStruct *FNS = (struct UPnPFragmentNotifyStruct*)data;
	int timeout;
	int packetlength;
	char* packet = (char*)malloc(5000);
	int i,i2;
	struct sockaddr_in addr;
	int addrlen;
	struct in_addr interface_addr;
	
	memset((char *)&addr, 0, sizeof(addr));
	addr.sin_family = AF_INET;
	addr.sin_addr.s_addr = inet_addr(UPNP_GROUP);
	addr.sin_port = (unsigned short)htons(UPNP_PORT);
	addrlen = sizeof(addr);
	
	memset((char *)&interface_addr, 0, sizeof(interface_addr));
	
	for(i=0;i<FNS->upnp->AddressListLength;++i)
	{
		interface_addr.s_addr = FNS->upnp->AddressList[i];
		if (setsockopt(FNS->upnp->NOTIFY_SEND_socks[i], IPPROTO_IP, IP_MULTICAST_IF,(char*)&interface_addr, sizeof(interface_addr)) == 0)
		{
			for (i2=0;i2<2;i2++)
			{
				switch(FNS->packetNumber)
				{
					case 1:
					UPnPBuildSsdpNotifyPacket(packet,&packetlength,FNS->upnp->AddressList[i],(unsigned short)FNS->upnp->WebSocketPortNumber,0,FNS->upnp->UDN,"::upnp:rootdevice","upnp:rootdevice","",FNS->upnp->NotifyCycleTime);
					sendto(FNS->upnp->NOTIFY_SEND_socks[i], packet, packetlength, 0, (struct sockaddr *) &addr, addrlen);
					break;
					case 2:
					UPnPBuildSsdpNotifyPacket(packet,&packetlength,FNS->upnp->AddressList[i],(unsigned short)FNS->upnp->WebSocketPortNumber,0,FNS->upnp->UDN,"","uuid:",FNS->upnp->UDN,FNS->upnp->NotifyCycleTime);
					sendto(FNS->upnp->NOTIFY_SEND_socks[i], packet, packetlength, 0, (struct sockaddr *) &addr, addrlen);
					break;
					case 3:
					UPnPBuildSsdpNotifyPacket(packet,&packetlength,FNS->upnp->AddressList[i],(unsigned short)FNS->upnp->WebSocketPortNumber,0,FNS->upnp->UDN,"::urn:schemas-upnp-org:device:Sample:1","urn:schemas-upnp-org:device:Sample:1","",FNS->upnp->NotifyCycleTime);
					sendto(FNS->upnp->NOTIFY_SEND_socks[i], packet, packetlength, 0, (struct sockaddr *) &addr, addrlen);
					break;
					case 4:
					UPnPBuildSsdpNotifyPacket(packet,&packetlength,FNS->upnp->AddressList[i],(unsigned short)FNS->upnp->WebSocketPortNumber,0,FNS->upnp->UDN,"::urn:schemas-upnp-org:service::1","urn:schemas-upnp-org:service::1","",FNS->upnp->NotifyCycleTime);
					sendto(FNS->upnp->NOTIFY_SEND_socks[i], packet, packetlength, 0, (struct sockaddr *) &addr, addrlen);
					break;
					
				}
			}
		}
	}
	free(packet);
	timeout = (int)((FNS->upnp->NotifyCycleTime/4) + ((unsigned short)rand() % (FNS->upnp->NotifyCycleTime/2 - FNS->upnp->NotifyCycleTime/4)));
	ILibLifeTime_Add(FNS->upnp->WebServerTimer,FNS,timeout,&UPnPFragmentedSendNotify,&UPnPFragmentedSendNotify_Destroy);
}
void UPnPSendNotify(const struct UPnPDataObject *upnp)
{
	int packetlength;
	char* packet = (char*)malloc(5000);
	int i,i2;
	struct sockaddr_in addr;
	int addrlen;
	struct in_addr interface_addr;
	
	memset((char *)&addr, 0, sizeof(addr));
	addr.sin_family = AF_INET;
	addr.sin_addr.s_addr = inet_addr(UPNP_GROUP);
	addr.sin_port = (unsigned short)htons(UPNP_PORT);
	addrlen = sizeof(addr);
	
	memset((char *)&interface_addr, 0, sizeof(interface_addr));
	
	for(i=0;i<upnp->AddressListLength;++i)
	{
		interface_addr.s_addr = upnp->AddressList[i];
		#if !defined(_WIN32_WCE) || (defined(_WIN32_WCE) && _WIN32_WCE>=4)
		if (setsockopt(upnp->NOTIFY_SEND_socks[i], IPPROTO_IP, IP_MULTICAST_IF,(char*)&interface_addr, sizeof(interface_addr)) == 0)
		{
			#endif
			for (i2=0;i2<2;i2++)
			{
				UPnPBuildSsdpNotifyPacket(packet,&packetlength,upnp->AddressList[i],(unsigned short)upnp->WebSocketPortNumber,0,upnp->UDN,"::upnp:rootdevice","upnp:rootdevice","",upnp->NotifyCycleTime);
				if (sendto(upnp->NOTIFY_SEND_socks[i], packet, packetlength, 0, (struct sockaddr *) &addr, addrlen) < 0) {exit(1);}
				UPnPBuildSsdpNotifyPacket(packet,&packetlength,upnp->AddressList[i],(unsigned short)upnp->WebSocketPortNumber,0,upnp->UDN,"","uuid:",upnp->UDN,upnp->NotifyCycleTime);
				if (sendto(upnp->NOTIFY_SEND_socks[i], packet, packetlength, 0, (struct sockaddr *) &addr, addrlen) < 0) {exit(1);}
				UPnPBuildSsdpNotifyPacket(packet,&packetlength,upnp->AddressList[i],(unsigned short)upnp->WebSocketPortNumber,0,upnp->UDN,"::urn:schemas-upnp-org:device:Sample:1","urn:schemas-upnp-org:device:Sample:1","",upnp->NotifyCycleTime);
				if (sendto(upnp->NOTIFY_SEND_socks[i], packet, packetlength, 0, (struct sockaddr *) &addr, addrlen) < 0) {exit(1);}
				UPnPBuildSsdpNotifyPacket(packet,&packetlength,upnp->AddressList[i],(unsigned short)upnp->WebSocketPortNumber,0,upnp->UDN,"::urn:schemas-upnp-org:service::1","urn:schemas-upnp-org:service::1","",upnp->NotifyCycleTime);
				if (sendto(upnp->NOTIFY_SEND_socks[i], packet, packetlength, 0, (struct sockaddr *) &addr, addrlen) < 0) {exit(1);}
				
			}
			#if !defined(_WIN32_WCE) || (defined(_WIN32_WCE) && _WIN32_WCE>=4)
		}
		#endif
	}
	free(packet);
}

#define UPnPBuildSsdpByeByePacket(outpacket,outlength,USN,USNex,NT,NTex,DeviceID)\
{\
	if(DeviceID==0)\
	{\
		*outlength = sprintf(outpacket,"NOTIFY * HTTP/1.1\r\nHOST: 239.255.255.250:1900\r\nNTS: ssdp:byebye\r\nUSN: uuid:%s%s\r\nNT: %s%s\r\nContent-Length: 0\r\n\r\n",USN,USNex,NT,NTex);\
	}\
	else\
	{\
		if(memcmp(NT,"uuid:",5)==0)\
		{\
			*outlength = sprintf(outpacket,"NOTIFY * HTTP/1.1\r\nHOST: 239.255.255.250:1900\r\nNTS: ssdp:byebye\r\nUSN: uuid:%s_%d%s\r\nNT: %s%s_%d\r\nContent-Length: 0\r\n\r\n",USN,DeviceID,USNex,NT,NTex,DeviceID);\
		}\
		else\
		{\
			*outlength = sprintf(outpacket,"NOTIFY * HTTP/1.1\r\nHOST: 239.255.255.250:1900\r\nNTS: ssdp:byebye\r\nUSN: uuid:%s_%d%s\r\nNT: %s%s\r\nContent-Length: 0\r\n\r\n",USN,DeviceID,USNex,NT,NTex);\
		}\
	}\
}


void UPnPSendByeBye(const struct UPnPDataObject *upnp)
{
	int TempVal=0;
	int packetlength;
	char* packet = (char*)malloc(5000);
	int i, i2;
	struct sockaddr_in addr;
	int addrlen;
	struct in_addr interface_addr;
	
	memset((char *)&addr, 0, sizeof(addr));
	addr.sin_family = AF_INET;
	addr.sin_addr.s_addr = inet_addr(UPNP_GROUP);
	addr.sin_port = (unsigned short)htons(UPNP_PORT);
	addrlen = sizeof(addr);
	
	memset((char *)&interface_addr, 0, sizeof(interface_addr));
	
	for(i=0;i<upnp->AddressListLength;++i)
	{
		
		interface_addr.s_addr = upnp->AddressList[i];
		#if !defined(_WIN32_WCE) || (defined(_WIN32_WCE) && _WIN32_WCE>=4)
		if (setsockopt(upnp->NOTIFY_SEND_socks[i], IPPROTO_IP, IP_MULTICAST_IF,(char*)&interface_addr, sizeof(interface_addr)) == 0)
		{
			#endif		
			
			for (i2=0;i2<2;i2++)
			{
				UPnPBuildSsdpByeByePacket(packet,&packetlength,upnp->UDN,"::upnp:rootdevice","upnp:rootdevice","",0);
				if (sendto(upnp->NOTIFY_SEND_socks[i], packet, packetlength, 0, (struct sockaddr *) &addr, addrlen) < 0) exit(1);
				UPnPBuildSsdpByeByePacket(packet,&packetlength,upnp->UDN,"","uuid:",upnp->UDN,0);
				if (sendto(upnp->NOTIFY_SEND_socks[i], packet, packetlength, 0, (struct sockaddr *) &addr, addrlen) < 0) exit(1);
				UPnPBuildSsdpByeByePacket(packet,&packetlength,upnp->UDN,"::urn:schemas-upnp-org:device:Sample:1","urn:schemas-upnp-org:device:Sample:1","",0);
				if (sendto(upnp->NOTIFY_SEND_socks[i], packet, packetlength, 0, (struct sockaddr *) &addr, addrlen) < 0) exit(1);
				UPnPBuildSsdpByeByePacket(packet,&packetlength,upnp->UDN,"::urn:schemas-upnp-org:service::1","urn:schemas-upnp-org:service::1","",0);
				if (sendto(upnp->NOTIFY_SEND_socks[i], packet, packetlength, 0, (struct sockaddr *) &addr, addrlen) < 0) exit(1);
				
			}
			#if !defined(_WIN32_WCE) || (defined(_WIN32_WCE) && _WIN32_WCE>=4)
		}
		#endif
	}
	free(packet);
}

/*! \fn UPnPResponse_Error(const UPnPSessionToken UPnPToken, const int ErrorCode, const char* ErrorMsg)
\brief Responds to the client invocation with a SOAP Fault
\param UPnPToken UPnP token
\param ErrorCode Fault Code
\param ErrorMsg Error Detail
*/
void UPnPResponse_Error(const UPnPSessionToken UPnPToken, const int ErrorCode, const char* ErrorMsg)
{
	char* body;
	int bodylength;
	char* head;
	int headlength;
	body = (char*)malloc(395 + (int)strlen(ErrorMsg));
	bodylength = sprintf(body,"<s:Envelope\r\n xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\" s:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\"><s:Body><s:Fault><faultcode>s:Client</faultcode><faultstring>UPnPError</faultstring><detail><UPnPError xmlns=\"urn:schemas-upnp-org:control-1-0\"><errorCode>%d</errorCode><errorDescription>%s</errorDescription></UPnPError></detail></s:Fault></s:Body></s:Envelope>",ErrorCode,ErrorMsg);
	head = (char*)malloc(59);
	headlength = sprintf(head,"HTTP/1.1 500 Internal\r\nContent-Length: %d\r\n\r\n",bodylength);
	ILibWebServer_Send_Raw((struct ILibWebServer_Session*)UPnPToken,head,headlength,0,0);
	ILibWebServer_Send_Raw((struct ILibWebServer_Session*)UPnPToken,body,bodylength,0,1);
}

/*! \fn UPnPGetLocalInterfaceToHost(const UPnPSessionToken UPnPToken)
\brief When a UPnP request is dispatched, this method determines which ip address actually received this request
\param UPnPToken UPnP token
\returns IP Address
*/
int UPnPGetLocalInterfaceToHost(const UPnPSessionToken UPnPToken)
{
	return(ILibWebServer_GetLocalInterface((struct ILibWebServer_Session*)UPnPToken));
}

void UPnPResponseGeneric(const UPnPMicroStackToken UPnPToken,const char* ServiceURI,const char* MethodName,const char* Params)
{
	char* packet;
	int packetlength;
	struct ILibWebServer_Session *session = (struct ILibWebServer_Session*)UPnPToken;
	int RVAL=0;
	
	packet = (char*)malloc(239+strlen(ServiceURI)+strlen(Params)+(strlen(MethodName)*2));
	packetlength = sprintf(packet,"<?xml version=\"1.0\" encoding=\"utf-8\"?>\r\n<s:Envelope s:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\" xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\"><s:Body><u:%sResponse xmlns:u=\"%s\">%s</u:%sResponse></s:Body></s:Envelope>",MethodName,ServiceURI,Params,MethodName);
	LVL3DEBUG(printf("SendBody: %s\r\n",packet);)
	#if defined(WIN32) || defined(_WIN32_WCE)
	RVAL=ILibWebServer_StreamHeader_Raw(session,200,"OK","\r\nEXT:\r\nCONTENT-TYPE: text/xml; charset=\"utf-8\"\r\nSERVER: WINDOWS, UPnP/1.0, Intel MicroStack/1.0.1868",1);
	#else
	RVAL=ILibWebServer_StreamHeader_Raw(session,200,"OK","\r\nEXT:\r\nCONTENT-TYPE: text/xml; charset=\"utf-8\"\r\nSERVER: POSIX, UPnP/1.0, Intel MicroStack/1.0.1868",1);
	#endif
	if(RVAL!=ILibAsyncSocket_SEND_ON_CLOSED_SOCKET_ERROR && RVAL != ILibWebServer_SEND_RESULTED_IN_DISCONNECT)
	{
		RVAL=ILibWebServer_StreamBody(session,packet,packetlength,0,1);
	}
}

/*! \fn UPnPResponse_ImportedService_getTcpServer(const UPnPSessionToken UPnPToken, const char* unescaped_a)
\brief Response Method for ImportedService >> urn:schemas-upnp-org:service::1 >> getTcpServer
\param UPnPToken MicroStack token
\param unescaped_a Value of argument a \b     Note: Automatically Escaped
*/
void UPnPResponse_ImportedService_getTcpServer(const UPnPSessionToken UPnPToken, const char* unescaped_a)
{
	char* body;
	char *a = (char*)malloc(1+ILibXmlEscapeLength(unescaped_a));
	
	ILibXmlEscape(a,unescaped_a);
	body = (char*)malloc(8+strlen(a));
	sprintf(body,"<a>%s</a>",a);
	UPnPResponseGeneric(UPnPToken,"urn:schemas-upnp-org:service::1","getTcpServer",body);
	free(body);
	free(a);
}

/*! \fn UPnPResponse_ImportedService_setForce(const UPnPSessionToken UPnPToken)
\brief Response Method for ImportedService >> urn:schemas-upnp-org:service::1 >> setForce
\param UPnPToken MicroStack token
*/
void UPnPResponse_ImportedService_setForce(const UPnPSessionToken UPnPToken)
{
	UPnPResponseGeneric(UPnPToken,"urn:schemas-upnp-org:service::1","setForce","");
}

/*! \fn UPnPResponse_ImportedService_setPage(const UPnPSessionToken UPnPToken)
\brief Response Method for ImportedService >> urn:schemas-upnp-org:service::1 >> setPage
\param UPnPToken MicroStack token
*/
void UPnPResponse_ImportedService_setPage(const UPnPSessionToken UPnPToken)
{
	UPnPResponseGeneric(UPnPToken,"urn:schemas-upnp-org:service::1","setPage","");
}

/*! \fn UPnPResponse_ImportedService_setSerial(const UPnPSessionToken UPnPToken)
\brief Response Method for ImportedService >> urn:schemas-upnp-org:service::1 >> setSerial
\param UPnPToken MicroStack token
*/
void UPnPResponse_ImportedService_setSerial(const UPnPSessionToken UPnPToken)
{
	UPnPResponseGeneric(UPnPToken,"urn:schemas-upnp-org:service::1","setSerial","");
}

/*! \fn UPnPResponse_ImportedService_setX(const UPnPSessionToken UPnPToken)
\brief Response Method for ImportedService >> urn:schemas-upnp-org:service::1 >> setX
\param UPnPToken MicroStack token
*/
void UPnPResponse_ImportedService_setX(const UPnPSessionToken UPnPToken)
{
	UPnPResponseGeneric(UPnPToken,"urn:schemas-upnp-org:service::1","setX","");
}

/*! \fn UPnPResponse_ImportedService_setY(const UPnPSessionToken UPnPToken)
\brief Response Method for ImportedService >> urn:schemas-upnp-org:service::1 >> setY
\param UPnPToken MicroStack token
*/
void UPnPResponse_ImportedService_setY(const UPnPSessionToken UPnPToken)
{
	UPnPResponseGeneric(UPnPToken,"urn:schemas-upnp-org:service::1","setY","");
}



void UPnPSendEventSink(
void *WebReaderToken,
int IsInterrupt,
struct packetheader *header,
char *buffer,
int *p_BeginPointer,
int EndPointer,
int done,
void *subscriber,
void *upnp,
int *PAUSE)	
{
	if(done!=0 && ((struct SubscriberInfo*)subscriber)->Disposing==0)
	{
		sem_wait(&(((struct UPnPDataObject*)upnp)->EventLock));
		--((struct SubscriberInfo*)subscriber)->RefCount;
		if(((struct SubscriberInfo*)subscriber)->RefCount==0)
		{
			LVL3DEBUG(printf("\r\n\r\nSubscriber at [%s] %d.%d.%d.%d:%d was/did UNSUBSCRIBE while trying to send event\r\n\r\n",((struct SubscriberInfo*)subscriber)->SID,(((struct SubscriberInfo*)subscriber)->Address&0xFF),((((struct SubscriberInfo*)subscriber)->Address>>8)&0xFF),((((struct SubscriberInfo*)subscriber)->Address>>16)&0xFF),((((struct SubscriberInfo*)subscriber)->Address>>24)&0xFF),((struct SubscriberInfo*)subscriber)->Port);)
			UPnPDestructSubscriberInfo(((struct SubscriberInfo*)subscriber));
		}
		else if(header==NULL)
		{
			LVL3DEBUG(printf("\r\n\r\nCould not deliver event for [%s] %d.%d.%d.%d:%d UNSUBSCRIBING\r\n\r\n",((struct SubscriberInfo*)subscriber)->SID,(((struct SubscriberInfo*)subscriber)->Address&0xFF),((((struct SubscriberInfo*)subscriber)->Address>>8)&0xFF),((((struct SubscriberInfo*)subscriber)->Address>>16)&0xFF),((((struct SubscriberInfo*)subscriber)->Address>>24)&0xFF),((struct SubscriberInfo*)subscriber)->Port);)
			// Could not send Event, so unsubscribe the subscriber
			((struct SubscriberInfo*)subscriber)->Disposing = 1;
			UPnPExpireSubscriberInfo(upnp,subscriber);
		}
		sem_post(&(((struct UPnPDataObject*)upnp)->EventLock));
	}
}
void UPnPSendEvent_Body(void *upnptoken,char *body,int bodylength,struct SubscriberInfo *info)
{
	struct UPnPDataObject* UPnPObject = (struct UPnPDataObject*)upnptoken;
	struct sockaddr_in dest;
	int packetLength;
	char *packet;
	int ipaddr;
	
	memset(&dest,0,sizeof(dest));
	dest.sin_addr.s_addr = info->Address;
	dest.sin_port = htons(info->Port);
	dest.sin_family = AF_INET;
	ipaddr = info->Address;
	
	packet = (char*)malloc(info->PathLength + bodylength + 483);
	packetLength = sprintf(packet,"NOTIFY %s HTTP/1.0\r\nSERVER: %s, UPnP/1.0, Intel MicroStack/1.0.1868\r\nHOST: %d.%d.%d.%d:%d\r\nContent-Type: text/xml; charset=\"utf-8\"\r\nNT: upnp:event\r\nNTS: upnp:propchange\r\nSID: %s\r\nSEQ: %d\r\nContent-Length: %d\r\n\r\n<?xml version=\"1.0\" encoding=\"utf-8\"?><e:propertyset xmlns:e=\"urn:schemas-upnp-org:event-1-0\"><e:property><%s></e:property></e:propertyset>",info->Path,UPnPPLATFORM,(ipaddr&0xFF),((ipaddr>>8)&0xFF),((ipaddr>>16)&0xFF),((ipaddr>>24)&0xFF),info->Port,info->SID,info->SEQ,bodylength+137,body);
	++info->SEQ;
	
	++info->RefCount;
	ILibWebClient_PipelineRequestEx(UPnPObject->EventClient,&dest,packet,packetLength,0,NULL,0,0,&UPnPSendEventSink,info,upnptoken);
}
void UPnPSendEvent(void *upnptoken, char* body, const int bodylength, const char* eventname)
{
	struct SubscriberInfo *info = NULL;
	struct UPnPDataObject* UPnPObject = (struct UPnPDataObject*)upnptoken;
	struct sockaddr_in dest;
	LVL3DEBUG(struct timeval tv;)
	
	if(UPnPObject==NULL)
	{
		free(body);
		return;
	}
	sem_wait(&(UPnPObject->EventLock));
	if(strncmp(eventname,"ImportedService",15)==0)
	{
		info = UPnPObject->HeadSubscriberPtr_ImportedService;
	}
	
	memset(&dest,0,sizeof(dest));
	while(info!=NULL)
	{
		if(!UPnPSubscriptionExpired(info))
		{
			UPnPSendEvent_Body(upnptoken,body,bodylength,info);
		}
		else
		{
			//Remove Subscriber
			#if defined(WIN32) || defined(_WIN32_WCE)
			LVL3DEBUG(printf("\r\n\r\nTIMESTAMP: %d\r\n",GetTickCount()/1000);)
			#else
			LVL3DEBUG(gettimeofday(&tv,NULL);)
			LVL3DEBUG(printf("\r\n\r\nTIMESTAMP: %d\r\n",tv.tv_sec);)
			#endif
			LVL3DEBUG(printf("Did not renew [%s] %d.%d.%d.%d:%d UNSUBSCRIBING <%d>\r\n\r\n",((struct SubscriberInfo*)info)->SID,(((struct SubscriberInfo*)info)->Address&0xFF),((((struct SubscriberInfo*)info)->Address>>8)&0xFF),((((struct SubscriberInfo*)info)->Address>>16)&0xFF),((((struct SubscriberInfo*)info)->Address>>24)&0xFF),((struct SubscriberInfo*)info)->Port,info);)
		}
		
		info = info->Next;
	}
	
	sem_post(&(UPnPObject->EventLock));
}

/*! \fn UPnPSetState_ImportedService_page(UPnPMicroStackToken upnptoken, char* val)
\brief Sets the state of page << urn:schemas-upnp-org:service::1 << ImportedService \para
\b Note: Must be called at least once prior to start
\param upnptoken The MicroStack token
\param val The new value of the state variable
*/
void UPnPSetState_ImportedService_page(UPnPMicroStackToken upnptoken, char* val)
{
	struct UPnPDataObject *UPnPObject = (struct UPnPDataObject*)upnptoken;
	char* body;
	int bodylength;
	char* valstr;
	valstr = (char*)malloc(ILibXmlEscapeLength(val)+1);
	ILibXmlEscape(valstr,val);
	if (UPnPObject->ImportedService_page != NULL) free(UPnPObject->ImportedService_page);
	UPnPObject->ImportedService_page = valstr;
	body = (char*)malloc(18 + (int)strlen(valstr));
	bodylength = sprintf(body,"%s>%s</%s","page",valstr,"page");
	UPnPSendEvent(upnptoken,body,bodylength,"ImportedService");
	free(body);
}

/*! \fn UPnPSetState_ImportedService_x(UPnPMicroStackToken upnptoken, int val)
\brief Sets the state of x << urn:schemas-upnp-org:service::1 << ImportedService \para
\b Note: Must be called at least once prior to start
\param upnptoken The MicroStack token
\param val The new value of the state variable
*/
void UPnPSetState_ImportedService_x(UPnPMicroStackToken upnptoken, int val)
{
	struct UPnPDataObject *UPnPObject = (struct UPnPDataObject*)upnptoken;
	char* body;
	int bodylength;
	char* valstr;
	valstr = (char*)malloc(10);
	sprintf(valstr,"%d",val);
	if (UPnPObject->ImportedService_x != NULL) free(UPnPObject->ImportedService_x);
	UPnPObject->ImportedService_x = valstr;
	body = (char*)malloc(12 + (int)strlen(valstr));
	bodylength = sprintf(body,"%s>%s</%s","x",valstr,"x");
	UPnPSendEvent(upnptoken,body,bodylength,"ImportedService");
	free(body);
}

/*! \fn UPnPSetState_ImportedService_y(UPnPMicroStackToken upnptoken, int val)
\brief Sets the state of y << urn:schemas-upnp-org:service::1 << ImportedService \para
\b Note: Must be called at least once prior to start
\param upnptoken The MicroStack token
\param val The new value of the state variable
*/
void UPnPSetState_ImportedService_y(UPnPMicroStackToken upnptoken, int val)
{
	struct UPnPDataObject *UPnPObject = (struct UPnPDataObject*)upnptoken;
	char* body;
	int bodylength;
	char* valstr;
	valstr = (char*)malloc(10);
	sprintf(valstr,"%d",val);
	if (UPnPObject->ImportedService_y != NULL) free(UPnPObject->ImportedService_y);
	UPnPObject->ImportedService_y = valstr;
	body = (char*)malloc(12 + (int)strlen(valstr));
	bodylength = sprintf(body,"%s>%s</%s","y",valstr,"y");
	UPnPSendEvent(upnptoken,body,bodylength,"ImportedService");
	free(body);
}

/*! \fn UPnPSetState_ImportedService_serial(UPnPMicroStackToken upnptoken, char* val)
\brief Sets the state of serial << urn:schemas-upnp-org:service::1 << ImportedService \para
\b Note: Must be called at least once prior to start
\param upnptoken The MicroStack token
\param val The new value of the state variable
*/
void UPnPSetState_ImportedService_serial(UPnPMicroStackToken upnptoken, char* val)
{
	struct UPnPDataObject *UPnPObject = (struct UPnPDataObject*)upnptoken;
	char* body;
	int bodylength;
	char* valstr;
	valstr = (char*)malloc(ILibXmlEscapeLength(val)+1);
	ILibXmlEscape(valstr,val);
	if (UPnPObject->ImportedService_serial != NULL) free(UPnPObject->ImportedService_serial);
	UPnPObject->ImportedService_serial = valstr;
	body = (char*)malloc(22 + (int)strlen(valstr));
	bodylength = sprintf(body,"%s>%s</%s","serial",valstr,"serial");
	UPnPSendEvent(upnptoken,body,bodylength,"ImportedService");
	free(body);
}

/*! \fn UPnPSetState_ImportedService_force(UPnPMicroStackToken upnptoken, int val)
\brief Sets the state of force << urn:schemas-upnp-org:service::1 << ImportedService \para
\b Note: Must be called at least once prior to start
\param upnptoken The MicroStack token
\param val The new value of the state variable
*/
void UPnPSetState_ImportedService_force(UPnPMicroStackToken upnptoken, int val)
{
	struct UPnPDataObject *UPnPObject = (struct UPnPDataObject*)upnptoken;
	char* body;
	int bodylength;
	char* valstr;
	valstr = (char*)malloc(10);
	sprintf(valstr,"%d",val);
	if (UPnPObject->ImportedService_force != NULL) free(UPnPObject->ImportedService_force);
	UPnPObject->ImportedService_force = valstr;
	body = (char*)malloc(20 + (int)strlen(valstr));
	bodylength = sprintf(body,"%s>%s</%s","force",valstr,"force");
	UPnPSendEvent(upnptoken,body,bodylength,"ImportedService");
	free(body);
}



void UPnPDestroyMicroStack(void *object)
{
	struct UPnPDataObject *upnp = (struct UPnPDataObject*)object;
	struct SubscriberInfo  *sinfo,*sinfo2;
	UPnPSendByeBye(upnp);
	
	sem_destroy(&(upnp->EventLock));
	
	free(upnp->ImportedService_page);
	free(upnp->ImportedService_x);
	free(upnp->ImportedService_y);
	free(upnp->ImportedService_serial);
	free(upnp->ImportedService_force);
	
	
	free(upnp->AddressList);
	free(upnp->NOTIFY_SEND_socks);
	free(upnp->UUID);
	free(upnp->Serial);
	free(upnp->DeviceDescription);
	
	sinfo = upnp->HeadSubscriberPtr_ImportedService;
	while(sinfo!=NULL)
	{
		sinfo2 = sinfo->Next;
		UPnPDestructSubscriberInfo(sinfo);
		sinfo = sinfo2;
	}
	
	
	#if defined(WIN32) || defined(_WIN32_WCE)
	WSACleanup();
	#endif
}
int UPnPGetLocalPortNumber(UPnPSessionToken token)
{
	return(ILibWebServer_GetPortNumber(((struct ILibWebServer_Session*)token)->Parent));
}
void UPnPSessionReceiveSink(
struct ILibWebServer_Session *sender,
int InterruptFlag,
struct packetheader *header,
char *bodyBuffer,
int *beginPointer,
int endPointer,
int done)
{
	if(header!=NULL && done !=0 && InterruptFlag==0)
	{
		UPnPProcessHTTPPacket(sender,header,bodyBuffer,beginPointer==NULL?0:*beginPointer,endPointer);
		if(beginPointer!=NULL) {*beginPointer = endPointer;}
	}
}
void UPnPSessionSink(struct ILibWebServer_Session *SessionToken, void *user)
{
	SessionToken->OnReceive = &UPnPSessionReceiveSink;
	SessionToken->User = user;
}
UPnPMicroStackToken UPnPCreateMicroStack(void *Chain, const char* FriendlyName,const char* UDN, const char* SerialNumber, const int NotifyCycleSeconds, const unsigned short PortNum)

{
	struct UPnPDataObject* RetVal = (struct UPnPDataObject*)malloc(sizeof(struct UPnPDataObject));
	char* DDT;
	
	#if defined(WIN32) || defined(_WIN32_WCE)
	WORD wVersionRequested;
	WSADATA wsaData;
	srand((int)GetTickCount());
	#ifdef WINSOCK1
	wVersionRequested = MAKEWORD( 1, 1 );	
	#elif WINSOCK2
	wVersionRequested = MAKEWORD( 2, 0 );
	#endif
	if (WSAStartup( wVersionRequested, &wsaData ) != 0) {exit(1);}
	#else
	struct timeval tv;
	gettimeofday(&tv,NULL);
	srand((int)tv.tv_sec);
	#endif
	
	UPnPInit(RetVal,NotifyCycleSeconds,PortNum);
	RetVal->ForceExit = 0;
	RetVal->PreSelect = &UPnPMasterPreSelect;
	RetVal->PostSelect = &UPnPMasterPostSelect;
	RetVal->Destroy = &UPnPDestroyMicroStack;
	RetVal->InitialNotify = 0;
	if (UDN != NULL)
	{
		RetVal->UUID = (char*)malloc((int)strlen(UDN)+6);
		sprintf(RetVal->UUID,"uuid:%s",UDN);
		RetVal->UDN = RetVal->UUID + 5;
	}
	if (SerialNumber != NULL)
	{
		RetVal->Serial = (char*)malloc((int)strlen(SerialNumber)+1);
		strcpy(RetVal->Serial,SerialNumber);
	}
	
	RetVal->DeviceDescription = (char*)malloc(10+UPnPDeviceDescriptionTemplateLengthUX+ (int)strlen(FriendlyName)  + (((int)strlen(RetVal->Serial) + (int)strlen(RetVal->UUID)) * 1));
	
	
	RetVal->WebServerTimer = ILibCreateLifeTime(Chain);
	
	RetVal->HTTPServer = ILibWebServer_Create(Chain,UPNP_HTTP_MAXSOCKETS,PortNum,&UPnPSessionSink,RetVal);
	RetVal->WebSocketPortNumber=(int)ILibWebServer_GetPortNumber(RetVal->HTTPServer);
	
	
	
	ILibAddToChain(Chain,RetVal);
	RetVal->EventClient = ILibCreateWebClient(5,Chain);
	RetVal->Chain = Chain;
	RetVal->UpdateFlag = 0;
	
	DDT = ILibDecompressString((char*)UPnPDeviceDescriptionTemplate,UPnPDeviceDescriptionTemplateLength,UPnPDeviceDescriptionTemplateLengthUX);
	RetVal->DeviceDescriptionLength = sprintf(RetVal->DeviceDescription,DDT,FriendlyName,RetVal->Serial,RetVal->UDN);
	
	free(DDT);
	
	sem_init(&(RetVal->EventLock),0,1);
	return(RetVal);
}







