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
    public partial class CodeForm : Form
    {
        private char[,] data;

        public char[,] Data
        {
            set
            {
                data = value;

                for (int j = 0; j < 16; j++)
                {
                    textBox1.Text += "\tDB ";

                    for (int i = 0; i < 64; i++)
                    {
                        if (i != 0)
                            textBox1.Text += ",";

                        if (data[i, j] == 'X')
                            textBox1.Text += "0FFh";
                        else
                            textBox1.Text += "20h";
                    }
                    textBox1.Text += "\r\n";
                }
            }
        }

        public string CodeText
        {

            get
            {
                return textBox1.Text;
            }
            set
            {
                textBox1.Text = value;
            }

        }

        public CodeForm()
        {
            InitializeComponent();


        }




    }
}
