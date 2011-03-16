// Intel's UPnP .NET Framework Device Stack, Device Module
// Intel Device Builder Build#1.0.1868.18043

using System;
using Intel.UPNP;
using Intel.DeviceBuilder;
using System.Net;
using System.Net.Sockets;
using System.Threading;

namespace Intel.DeviceBuilder
{
	/// <summary>
	/// Summary description for SampleDevice.
	/// </summary>
	public class SampleDevice
	{
		private UPnPDevice device;
		private Intel.DeviceBuilder.ImportedService ImportedService;
		private int port;
		private TcpListener tcpListener;
		
			public SampleDevice()
		{
			device = UPnPDevice.CreateRootDevice(20,1.0,"\\");
			device.FriendlyName = "Anoto Bridge";
			device.Manufacturer = "Intel Corporation";
			device.ManufacturerURL = "http://www.intel.com";
			device.ModelName = "Sample Auto-Generated Device";
			device.ModelDescription = "Sample UPnP Device Using Auto-Generated UPnP Stack";
			device.ModelNumber = "X1";
			device.HasPresentation = false;
			device.DeviceURN = "urn:schemas-upnp-org:device:Sample:1";
			ImportedService = new Intel.DeviceBuilder.ImportedService();
			ImportedService.External_getTcpServer = new Intel.DeviceBuilder.ImportedService.Delegate_getTcpServer(ImportedService_getTcpServer);
			ImportedService.External_setForce = new Intel.DeviceBuilder.ImportedService.Delegate_setForce(ImportedService_setForce);
			ImportedService.External_setPage = new Intel.DeviceBuilder.ImportedService.Delegate_setPage(ImportedService_setPage);
			ImportedService.External_setSerial = new Intel.DeviceBuilder.ImportedService.Delegate_setSerial(ImportedService_setSerial);
			ImportedService.External_setX = new Intel.DeviceBuilder.ImportedService.Delegate_setX(ImportedService_setX);
			ImportedService.External_setY = new Intel.DeviceBuilder.ImportedService.Delegate_setY(ImportedService_setY);
			device.AddService(ImportedService);
			
			// Setting the initial value of evented variables
			ImportedService.Evented_page = "Sample String";
			ImportedService.Evented_x = 0;
			ImportedService.Evented_y = 0;
			ImportedService.Evented_serial = "Sample String";
			ImportedService.Evented_force = 0;
			ImportedService.tcpServer= "t";
		}
		
		public void Start()
		{
			device.StartDevice();
		}
		
		public void Stop()
		{
			device.StopDevice();
		}
		public void ImportedService_getTcpServer(out System.String a)
		{
			String hostname = Dns.GetHostName();
			IPHostEntry hostinfo = Dns.GetHostByName( hostname );
			a = "";
			foreach(IPAddress address in hostinfo.AddressList)
		      {
				a = (address+":"+((IPEndPoint)this.tcpListener.LocalEndpoint).Port);
		        // Console.WriteLine("Address: {0}",address.ToString());
		      }
			
			//Console.WriteLine("ImportedService_getTcpAdd(" + ")");
		}
		public void ImportedService_setSerial(System.String s){
			ImportedService.setSerial(s);
			//Console.WriteLine("ImportedService_setSerial(" + s.ToString() + ")");
		}
		public void ImportedService_setForce(System.Int32 f)
		{
			ImportedService.setForce(f);
		//	Console.WriteLine("ImportedService_setForce(" + f.ToString() + ")");
		}
		
		public void ImportedService_setPage(System.String p)
		{
			ImportedService.setPage(p);
		//	Console.WriteLine("ImportedService_setPage(" + p.ToString() + ")");
		}
		
		public void ImportedService_setX(System.Int32 x)
		{
			ImportedService.setX(x);
		//	Console.WriteLine("ImportedService_setX(" + x.ToString() + ")");
		}
		
		public void ImportedService_setY(System.Int32 y)
		{
			ImportedService.setY(y);
		//	Console.WriteLine("ImportedService_setY(" + y.ToString() + ")");
		}
		public void setTcpServerPort(int p){
			this.port = p;
		}
		public void setTcpListener(TcpListener tl){
			this.tcpListener = tl;
		}
	}
}

