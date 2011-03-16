/* UPnP Device Main Module */

#include "ILibParsers.h"
#include "UPnPMicroStack.h"
#include "ILibWebServer.h"
#include "ILibAsyncSocket.h"

void *UPnPmicroStackChain;
void *UPnPmicroStack;

void *UPnPMonitor;
int UPnPIPAddressLength;
int *UPnPIPAddressList;

void UPnPImportedService_getTcpServer(UPnPSessionToken upnptoken)
{
	printf("Invoke: UPnPImportedService_getTcpServer();\r\n");
	
	/* If you intend to make the response later, you MUST reference count upnptoken with calls to ILibWebServer_AddRef() */
	/* and ILibWebServer_Release() */
	
	/* TODO: Place Action Code Here... */
	
	/* UPnPResponse_Error(upnptoken,404,"Method Not Implemented"); */
	UPnPResponse_ImportedService_getTcpServer(upnptoken,"Sample String");
}

void UPnPImportedService_setForce(UPnPSessionToken upnptoken,int f)
{
	printf("Invoke: UPnPImportedService_setForce(%d);\r\n",f);
	
	/* If you intend to make the response later, you MUST reference count upnptoken with calls to ILibWebServer_AddRef() */
	/* and ILibWebServer_Release() */
	
	/* TODO: Place Action Code Here... */
	
	/* UPnPResponse_Error(upnptoken,404,"Method Not Implemented"); */
	UPnPResponse_ImportedService_setForce(upnptoken);
}

void UPnPImportedService_setPage(UPnPSessionToken upnptoken,char* p)
{
	printf("Invoke: UPnPImportedService_setPage(%s);\r\n",p);
	
	/* If you intend to make the response later, you MUST reference count upnptoken with calls to ILibWebServer_AddRef() */
	/* and ILibWebServer_Release() */
	
	/* TODO: Place Action Code Here... */
	
	/* UPnPResponse_Error(upnptoken,404,"Method Not Implemented"); */
	UPnPResponse_ImportedService_setPage(upnptoken);
}

void UPnPImportedService_setSerial(UPnPSessionToken upnptoken,char* s)
{
	printf("Invoke: UPnPImportedService_setSerial(%s);\r\n",s);
	
	/* If you intend to make the response later, you MUST reference count upnptoken with calls to ILibWebServer_AddRef() */
	/* and ILibWebServer_Release() */
	
	/* TODO: Place Action Code Here... */
	
	/* UPnPResponse_Error(upnptoken,404,"Method Not Implemented"); */
	UPnPResponse_ImportedService_setSerial(upnptoken);
}

void UPnPImportedService_setX(UPnPSessionToken upnptoken,int x)
{
	printf("Invoke: UPnPImportedService_setX(%d);\r\n",x);
	
	/* If you intend to make the response later, you MUST reference count upnptoken with calls to ILibWebServer_AddRef() */
	/* and ILibWebServer_Release() */
	
	/* TODO: Place Action Code Here... */
	
	/* UPnPResponse_Error(upnptoken,404,"Method Not Implemented"); */
	UPnPResponse_ImportedService_setX(upnptoken);
}

void UPnPImportedService_setY(UPnPSessionToken upnptoken,int y)
{
	printf("Invoke: UPnPImportedService_setY(%d);\r\n",y);
	
	/* If you intend to make the response later, you MUST reference count upnptoken with calls to ILibWebServer_AddRef() */
	/* and ILibWebServer_Release() */
	
	/* TODO: Place Action Code Here... */
	
	/* UPnPResponse_Error(upnptoken,404,"Method Not Implemented"); */
	UPnPResponse_ImportedService_setY(upnptoken);
}

void UPnPIPAddressMonitor(void *data)
{
	int length;
	int *list;
	
	length = ILibGetLocalIPAddressList(&list);
	if(length!=UPnPIPAddressLength || memcmp((void*)list,(void*)UPnPIPAddressList,sizeof(int)*length)!=0)
	{
		UPnPIPAddressListChanged(UPnPmicroStack);
		
		free(UPnPIPAddressList);
		UPnPIPAddressList = list;
		UPnPIPAddressLength = length;
	}
	else
	{
		free(list);
	}
	
	
	ILibLifeTime_Add(UPnPMonitor,NULL,4,&UPnPIPAddressMonitor,NULL);
}
void BreakSink(int s)
{
	ILibStopChain(UPnPmicroStackChain);
}
int main(void)
{
	UPnPmicroStackChain = ILibCreateChain();
	
	/* TODO: Each device must have a unique device identifier (UDN) */
	UPnPmicroStack = UPnPCreateMicroStack(UPnPmicroStackChain,"Sample Device","f8b67906-edb8-4701-a9b2-36c29262c82d","0000001",15,0);
	
	UPnPFP_ImportedService_getTcpServer=&UPnPImportedService_getTcpServer;
	UPnPFP_ImportedService_setForce=&UPnPImportedService_setForce;
	UPnPFP_ImportedService_setPage=&UPnPImportedService_setPage;
	UPnPFP_ImportedService_setSerial=&UPnPImportedService_setSerial;
	UPnPFP_ImportedService_setX=&UPnPImportedService_setX;
	UPnPFP_ImportedService_setY=&UPnPImportedService_setY;
	
	
	/* All evented state variables MUST be initialized before UPnPStart is called. */
	UPnPSetState_ImportedService_page(UPnPmicroStack,"Sample String");
	UPnPSetState_ImportedService_x(UPnPmicroStack,25000);
	UPnPSetState_ImportedService_y(UPnPmicroStack,25000);
	UPnPSetState_ImportedService_serial(UPnPmicroStack,"Sample String");
	UPnPSetState_ImportedService_force(UPnPmicroStack,25000);
	
	printf("Intel MicroStack 1.0 \r\n\r\n");
	
	UPnPMonitor = ILibCreateLifeTime(UPnPmicroStackChain);
	UPnPIPAddressLength = ILibGetLocalIPAddressList(&UPnPIPAddressList);
	ILibLifeTime_Add(UPnPMonitor,NULL,4,&UPnPIPAddressMonitor,NULL);
	
	signal(SIGINT,BreakSink);
	ILibStartChain(UPnPmicroStackChain);
	
	free(UPnPIPAddressList);
	return 0;
}

