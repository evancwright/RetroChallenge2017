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


    public partial class Form1 : Form
    {
        const int WIDTH_SCALE = 10;
        const int HEIGHT_SCALE = 20;
        char[,] screen = new char[64, 24];

        public Form1()
        {
            InitializeComponent();

            pictureBox1.Width = 64 * WIDTH_SCALE;
            pictureBox1.Height = 64 * HEIGHT_SCALE;
            Init();
        }

        void Init()
        {
            for (int i = 0; i < 64; i++)
            {
                for (int j = 0; j < 16; j++)
                {
                    screen[i, j] = ' ';
                }
            }
        }

        private void pictureBox1_Paint(object sender, PaintEventArgs e)
        {
            Brush black = Brushes.Black;
            Brush white = Brushes.White;

            for (int i = 0; i < 64; i++)
            {
                for (int j = 0; j < 16; j++)
                {
                    if (screen[i, j] == ' ')
                    {
                        e.Graphics.FillRectangle(black, i * WIDTH_SCALE, j * HEIGHT_SCALE, WIDTH_SCALE, HEIGHT_SCALE);
                    }
                    else
                    {
                        e.Graphics.FillRectangle(white, i * WIDTH_SCALE, j * HEIGHT_SCALE, WIDTH_SCALE, HEIGHT_SCALE);
                    }
                }
            }

        }

        private void pictureBox1_MouseClick(object sender, MouseEventArgs e)
        {
            int x = e.X / WIDTH_SCALE;
            int y = e.Y / HEIGHT_SCALE;

            if (screen[x,y]==' ')
                screen[x,y] = 'X';
            else
                screen[x,y] = ' ';

            pictureBox1.Invalidate();
        }

        private void toASMToolStripMenuItem_Click(object sender, EventArgs e)
        {
            CodeForm cf = new CodeForm();
            cf.Data = screen;
            cf.ShowDialog();
        }

        private void aboutToolStripMenuItem_Click(object sender, EventArgs e)
        {
            MessageBox.Show("By Evan Wright, 2018");
        }

        private void fromASMToolStripMenuItem_Click(object sender, EventArgs e)
        {
            EnterCodeForm ecf = new EnterCodeForm();
            ecf.ShowDialog();

            for (int i = 0; i < 60; i++)
            {
                for (int j = 0; j < 24; j++)
                {
                    screen[i, j] = ecf.screen[i, j];
                }
            }

            pictureBox1.Invalidate();
        }

        private void exitToolStripMenuItem_Click(object sender, EventArgs e)
        {
            Application.Exit();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            CodeForm cf = new CodeForm();
            int x = Convert.ToInt32(textBox1.Text);
            int y = Convert.ToInt32(textBox2.Text);
            int cols = Convert.ToInt32(textBox3.Text);
            int rows = Convert.ToInt32(textBox4.Text);

            for (int i = 0; i < rows; i++)
            {
                cf.CodeText += "\tDB ";
                for (int j = 0; j < cols; j++)
                {
                    if (j != 0)
                        cf.CodeText += ",";

                    if (screen[x+j, y+i] == 'X')
                        cf.CodeText += "0ffh";
                    else
                        cf.CodeText += "20h";
                }
                cf.CodeText += "\r\n";
            }
            cf.ShowDialog();
        }

        private void pictureBox1_MouseMove(object sender, MouseEventArgs e)
        {
            int x = e.X / WIDTH_SCALE;
            int y = e.Y / HEIGHT_SCALE;

            textBox5.Text = "" + x + "," + y;
        }
    }
}
