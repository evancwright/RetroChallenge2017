using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace TRS80ScreenMaker
{
    public partial class EnterCodeForm : Form
    {
        public char[,] screen = new char[64, 24];

        public EnterCodeForm()
        {
            InitializeComponent();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            string code = textBox1.Text;
            code = code.Replace('\r',' ');
            string[] lines = textBox1.Text.Split('\n');

            for (int i = 0; i < Math.Min(16,lines.Length); i++)
            {
                lines[i] = lines[i].Substring(4);

                string[] bytes = lines[i].Split(',');

                for (int j = 0; j < bytes.Length; j++)
                {
                    string val = bytes[j].Trim();

                    if (val == "20h")
                        screen[j, i] = ' ';
                    else
                        screen[j, i] = 'X' ;
                }
            }
            Close();
        }
    }
}
