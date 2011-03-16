// Intel's UPnP .NET Framework Device Stack, Core Module
// Intel Device Builder Build#1.0.1868.18043

using System;
using Intel.UPNP;
using Intel.DeviceBuilder;

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
			device.Start();
			System.Console.WriteLine("Press return to stop device.");
			System.Console.ReadLine();
			device.Stop();
		}
		
	}
}

