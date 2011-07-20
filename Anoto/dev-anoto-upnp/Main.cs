// Intel's UPnP .NET Framework Device Stack, Core Module
// Intel Device Builder Build#1.0.1868.18043

using System;
using System.Collections.Generic;
using System.Windows.Forms;
//using Intel.UPNP;
//using Intel.DeviceBuilder;

namespace Intel.DeviceBuilder
{
	/// <summary>
	/// Summary description for Main.
	/// </summary>
	class SampleDeviceMain
	{
		/// <summary>
		/// The main entry point for the application.
		/// </summary>
		[STAThread]
		static void Main(string[] args)
		{
			
			// Starting UPnP Device
			System.Console.WriteLine("Intel's UPnP .NET Framework Stack");
			System.Console.WriteLine("Intel Device Builder Build#1.0.1868.18043");
			
			SampleDevice device = new SampleDevice();
			System.Console.WriteLine("Device created");
			
			device.Start();
			System.Console.WriteLine("Press return to stop device.");
			Application.EnableVisualStyles();
			System.Console.WriteLine("Application Enable Visual") ; 
			Application.SetCompatibleTextRenderingDefault(false);
			System.Console.WriteLine("Compatible rendering");
			Form1 form = new Form1();
			System.Console.WriteLine("New form") ; 
			form.SetDevice(device);
			System.Console.WriteLine("Device Set") ; 
			device.setTcpListener(form.getTcpListener());
			System.Console.WriteLine("Listener Set") ;
			device.setTcpServerPort(form.getServerPort());
			System.Console.WriteLine("Port set"); 
			Application.Run(form);
			System.Console.WriteLine("Appluication running"); 
			System.Console.ReadLine();
			device.Stop();
			Console.WriteLine("end");
		}
		
	}
}

