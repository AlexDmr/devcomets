/*****************************************************************************
 * Copyright (c) 2009-2010 Anoto AB. All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 * Redistribution of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 * Redistribution in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 * Neither the name of Anoto AB nor the names of contributors may be used
 * to endorse or promote products derived from this software without
 * specific prior written permission.
 * This software is provided "AS IS," without a warranty of any kind. ALL
 * EXPRESS OR IMPLIED CONDITIONS, REPRESENTATIONS AND WARRANTIES, INCLUDING
 * ANY IMPLIED WARRANTY OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
 * PURPOSE OR NON-INFRINGEMENT, ARE HEREBY EXCLUDED. ANOTO AB AND ITS
 * LICENSORS SHALL NOT BE LIABLE FOR ANY DAMAGES SUFFERED BY LICENSEE AS A
 * RESULT OF USING, MODIFYING OR DISTRIBUTING THIS SOFTWARE OR ITS
 * DERIVATIVES. IN NO EVENT WILL ANOTO AB OR ITS LICENSORS BE LIABLE FOR
 * ANY LOST REVENUE, PROFIT OR DATA, OR FOR DIRECT, INDIRECT, SPECIAL,
 * CONSEQUENTIAL, INCIDENTAL OR PUNITIVE DAMAGES, HOWEVER CAUSED AND
 * REGARDLESS OF THE THEORY OF LIABILITY, ARISING OUT OF THE USE OF OR
 * INABILITY TO USE THIS SOFTWARE, EVEN IF ANOTO AB HAS BEEN ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGES.
 ****************************************************************************/
namespace Intel.DeviceBuilder
{
	partial class Form1
	{
		/// <summary>
		/// Required designer variable.
		/// </summary>
		private System.ComponentModel.IContainer components = null;
		
		/// <summary>
		/// Clean up any resources being used.
		/// </summary>
		/// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
		protected override void Dispose(bool disposing)
		{
			if (disposing && (components != null))
			{
				// release memory allocated by AnotoGenericStreamer
				ReleaseGenericStreamer();
				components.Dispose();
			}
			base.Dispose(disposing);
		}

		#region Windows Form Designer generated code

		/// <summary>
		/// Required method for Designer support - do not modify
		/// the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{
			this.components = new System.ComponentModel.Container();
			System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(Form1));
			this.ConnectedDevices = new System.Windows.Forms.GroupBox();
			this.ConnectedDevListView = new System.Windows.Forms.ListView();
			this.imageListPens = new System.Windows.Forms.ImageList(this.components);
			this.pictureBox = new System.Windows.Forms.PictureBox();
			this.clearBtn = new System.Windows.Forms.Button();
			this.menuStrip1 = new System.Windows.Forms.MenuStrip();
			this.fileToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
			this.exitMnu = new System.Windows.Forms.ToolStripMenuItem();
			this.helpToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
			this.aboutMnu = new System.Windows.Forms.ToolStripMenuItem();
			this.ConnectedDevices.SuspendLayout();
			((System.ComponentModel.ISupportInitialize)(this.pictureBox)).BeginInit();
			this.menuStrip1.SuspendLayout();
			this.SuspendLayout();
			// 
			// ConnectedDevices
			// 
			this.ConnectedDevices.Controls.Add(this.ConnectedDevListView);
			this.ConnectedDevices.Location = new System.Drawing.Point(12, 33);
			this.ConnectedDevices.Name = "ConnectedDevices";
			this.ConnectedDevices.Size = new System.Drawing.Size(450, 112);
			this.ConnectedDevices.TabIndex = 0;
			this.ConnectedDevices.TabStop = false;
			this.ConnectedDevices.Text = "Connected devices";
			// 
			// ConnectedDevListView
			// 
			this.ConnectedDevListView.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left)
									| System.Windows.Forms.AnchorStyles.Right)));
			this.ConnectedDevListView.LabelWrap = false;
			this.ConnectedDevListView.LargeImageList = this.imageListPens;
			this.ConnectedDevListView.Location = new System.Drawing.Point(6, 18);
			this.ConnectedDevListView.MultiSelect = false;
			this.ConnectedDevListView.Name = "ConnectedDevListView";
			this.ConnectedDevListView.Size = new System.Drawing.Size(438, 86);
			this.ConnectedDevListView.TabIndex = 0;
			this.ConnectedDevListView.TabStop = false;
			this.ConnectedDevListView.UseCompatibleStateImageBehavior = false;
			// 
			// imageListPens
			// 
			//this.imageListPens.ImageStream = ((System.Windows.Forms.ImageListStreamer)(resources.GetObject("imageListPens.ImageStream")));
			this.imageListPens.TransparentColor = System.Drawing.Color.Transparent;
			//this.imageListPens.Images.SetKeyName(0, "pen.jpg");
			//this.imageListPens.Images.SetKeyName(1, "inputpen.JPG");
			// 
			// pictureBox
			// 
			this.pictureBox.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(255)))), ((int)(((byte)(225)))));
			this.pictureBox.BackgroundImageLayout = System.Windows.Forms.ImageLayout.None;
			this.pictureBox.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
			this.pictureBox.Location = new System.Drawing.Point(12, 163);
			this.pictureBox.Name = "pictureBox";
			this.pictureBox.Size = new System.Drawing.Size(450, 450);
			this.pictureBox.TabIndex = 1;
			this.pictureBox.TabStop = false;
			// 
			// clearBtn
			// 
			this.clearBtn.Location = new System.Drawing.Point(386, 627);
			this.clearBtn.Name = "clearBtn";
			this.clearBtn.Size = new System.Drawing.Size(75, 23);
			this.clearBtn.TabIndex = 2;
			this.clearBtn.Text = "Clear";
			this.clearBtn.UseVisualStyleBackColor = true;
			this.clearBtn.Click += new System.EventHandler(this.clearBtn_Click);
			// 
			// menuStrip1
			// 
			this.menuStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.fileToolStripMenuItem,
            this.helpToolStripMenuItem});
			this.menuStrip1.Location = new System.Drawing.Point(0, 0);
			this.menuStrip1.Name = "menuStrip1";
			this.menuStrip1.Size = new System.Drawing.Size(473, 24);
			this.menuStrip1.TabIndex = 3;
			this.menuStrip1.Text = "menuStrip1";
			// 
			// fileToolStripMenuItem
			// 
			this.fileToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.exitMnu});
			this.fileToolStripMenuItem.Name = "fileToolStripMenuItem";
			this.fileToolStripMenuItem.Size = new System.Drawing.Size(35, 20);
			this.fileToolStripMenuItem.Text = "File";
			// 
			// exitMnu
			// 
			this.exitMnu.Name = "exitMnu";
			this.exitMnu.Size = new System.Drawing.Size(103, 22);
			this.exitMnu.Text = "Exit";
			this.exitMnu.Click += new System.EventHandler(this.exitMnu_Click);
			// 
			// helpToolStripMenuItem
			// 
			this.helpToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.aboutMnu});
			this.helpToolStripMenuItem.Name = "helpToolStripMenuItem";
			this.helpToolStripMenuItem.Size = new System.Drawing.Size(40, 20);
			this.helpToolStripMenuItem.Text = "Help";
			// 
			// aboutMnu
			// 
			this.aboutMnu.Name = "aboutMnu";
			this.aboutMnu.Size = new System.Drawing.Size(191, 22);
			this.aboutMnu.Text = "About SimpleStreamer";
			this.aboutMnu.Click += new System.EventHandler(this.aboutMnu_Click);
			// 
			// Form1
			// 
			this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
			this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
			this.BackColor = System.Drawing.Color.WhiteSmoke;
			this.ClientSize = new System.Drawing.Size(473, 662);
			this.Controls.Add(this.clearBtn);
			this.Controls.Add(this.pictureBox);
			this.Controls.Add(this.ConnectedDevices);
			this.Controls.Add(this.menuStrip1);
			this.MainMenuStrip = this.menuStrip1;
			this.Name = "Form1";
			this.Text = "SimpleStreamer";
			this.Shown += new System.EventHandler(this.Form1_Shown);
			this.ConnectedDevices.ResumeLayout(false);
			((System.ComponentModel.ISupportInitialize)(this.pictureBox)).EndInit();
			this.menuStrip1.ResumeLayout(false);
			this.menuStrip1.PerformLayout();
			this.ResumeLayout(false);
			this.PerformLayout();

		}

		#endregion

		private System.Windows.Forms.GroupBox ConnectedDevices;
		private System.Windows.Forms.ListView ConnectedDevListView;
		private System.Windows.Forms.PictureBox pictureBox;
		private System.Windows.Forms.ImageList imageListPens;
		private System.Windows.Forms.Button clearBtn;
		private System.Windows.Forms.MenuStrip menuStrip1;
		private System.Windows.Forms.ToolStripMenuItem fileToolStripMenuItem;
		private System.Windows.Forms.ToolStripMenuItem exitMnu;
		private System.Windows.Forms.ToolStripMenuItem helpToolStripMenuItem;
		private System.Windows.Forms.ToolStripMenuItem aboutMnu;
	}
}

