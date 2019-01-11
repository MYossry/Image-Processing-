using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Runtime.InteropServices;


namespace CsharpGUI
{
    public partial class Form1 : Form
    {

        [DllImport("Project.dll")]
        public static extern int histo([In, Out] int[] redChannel, int imageSize);
          
        [DllImport("Project.dll")]
        private static extern int Sum(int y, int b);

        [DllImport("Project.dll")]
        private static extern int SumArr([In] int[] arr, int sz);

        [DllImport("Project.dll")]
        private static extern void ToUpper([In, Out]char[] arr, int sz);

        [DllImport("Project.dll")]
        private static extern void AddImages([In] int[] firstChannelToAdd, [In] int[] secondChannelToAdd
                                            , [Out] int[] output, int imageSize);


        [DllImport("Project.dll")]
        private static extern void SubImages([In] int[] firstChannelToSub, [In] int[] secondChannelToSub
                                            , [Out] int[] output, int imageSize);

        [DllImport("Project.dll")]
        private static extern void Invert([In, Out] int[] redChannel, [In, Out] int[] greenChannel,
                                            [In, Out] int[] blueChannel, int imageSize);

        [DllImport("Project.dll")]
        private static extern void sobel([In, Out] int[] redChannel, [In, Out] int[] greenChannel,int height,int weight,int imgsize, char dir);



        public ImageBuffers BuffersFirstImage
        {
            get
            {
                if (this.inputImage_pictureBox != null && this.inputImage_pictureBox.Image != null && FirstImage != null)
                {
                    return ImageHelper.GetBuffersFromImage(this.FirstImage);
                }
                return null;
            }
        }

        public ImageBuffers BuffersSecondImage
        {
            get
            {
                if (this.inputImage2_pictureBox1 != null && this.inputImage2_pictureBox1.Image != null && SecondImage != null)
                {
                    return ImageHelper.GetBuffersFromImage(this.SecondImage);
                }
                return null;
            }
        }


        public Bitmap FirstImage { get; set; }

        public Bitmap SecondImage { get; set; }
        public Form1()
        {
            InitializeComponent();
        }

        private void toolStripLabel1_Click(object sender, EventArgs e)
        {

        }

        private void openImageToolStripMenuItem_Click(object sender, EventArgs e)
        {
            Stream myStream = null;
            OpenFileDialog openFileDialog1 = new OpenFileDialog();
            openFileDialog1.InitialDirectory = "c:\\Libraries\\Pictures";
            openFileDialog1.Filter = "*.BMP;*.PPM;*.JPG;*.GIF)|*.BMP;*.JPG;*.GIF|All files (*.*)|*.*";
            openFileDialog1.FilterIndex = 2;
            openFileDialog1.RestoreDirectory = true;
            string fname = "";
            if (openFileDialog1.ShowDialog() == DialogResult.OK)
            {
                try
                {
                    if ((myStream = openFileDialog1.OpenFile()) != null)
                    {
                        string ext = Path.GetExtension(openFileDialog1.FileName);
                        fname = openFileDialog1.FileName;
                        using (myStream)
                        {
                            this.FirstImage = new Bitmap(myStream);
                            this.inputImage_pictureBox.Image = this.FirstImage;
                        }
                    }
                }
                catch (Exception ex)
                {
                    MessageBox.Show("Error: Could not read file from disk. Original error: " + ex.Message);
                }
            }
        }

        private void secondImage_button2_Click(object sender, EventArgs e)
        {
            Stream myStream = null;
            OpenFileDialog openFileDialog1 = new OpenFileDialog();
            openFileDialog1.InitialDirectory = "c:\\Libraries\\Pictures";
            openFileDialog1.Filter = "*.BMP;*.PPM;*.JPG;*.GIF)|*.BMP;*.JPG;*.GIF|All files (*.*)|*.*";
            openFileDialog1.FilterIndex = 2;
            openFileDialog1.RestoreDirectory = true;
            string fname = "";
            if (openFileDialog1.ShowDialog() == DialogResult.OK)
            {
                try
                {
                    if ((myStream = openFileDialog1.OpenFile()) != null)
                    {
                        string ext = Path.GetExtension(openFileDialog1.FileName);
                        fname = openFileDialog1.FileName;
                        using (myStream)
                        {
                            this.SecondImage = new Bitmap(myStream);
                            this.inputImage2_pictureBox1.Image = this.SecondImage;
                        }
                    }
                }
                catch (Exception ex)
                {
                    MessageBox.Show("Error: Could not read file from disk. Original error: " + ex.Message);
                }
            }
        }



        private void invert_button_Click(object sender, EventArgs e)
        {
            //Get first image buffers
            var buffersOfFirstImage = BuffersFirstImage;

            int width = buffersOfFirstImage.Width;
            int height = buffersOfFirstImage.Height;
            int imageSize = width * height;

            Invert(buffersOfFirstImage.RedChannel, buffersOfFirstImage.GreenChannel, buffersOfFirstImage.BlueChannel, imageSize);
            //Refelct the result to the GUI
            //1. Convert the output channels into bitmap
            var outputBuffersObject = ImageHelper.CreateNewImageBuffersObject(buffersOfFirstImage.RedChannel, buffersOfFirstImage.GreenChannel, buffersOfFirstImage.BlueChannel, width, height);
            this.outputImage_pictureBox.Image = (Bitmap)ImageHelper.GetImageFromBuffers(outputBuffersObject).BitmapObject;
        }

        private void equalize_button_Click(object sender, EventArgs e)
        {
            //Implement this function by your own
        }

        private void loadSecondImageToolStripMenuItem_Click(object sender, EventArgs e)
        {
            Stream myStream = null;
            OpenFileDialog openFileDialog1 = new OpenFileDialog();
            openFileDialog1.InitialDirectory = "c:\\Libraries\\Pictures";
            openFileDialog1.Filter = "*.BMP;*.PPM;*.JPG;*.GIF)|*.BMP;*.JPG;*.GIF|All files (*.*)|*.*";
            openFileDialog1.FilterIndex = 2;
            openFileDialog1.RestoreDirectory = true;
            string fname = "";
            if (openFileDialog1.ShowDialog() == DialogResult.OK)
            {
                try
                {
                    if ((myStream = openFileDialog1.OpenFile()) != null)
                    {
                        string ext = Path.GetExtension(openFileDialog1.FileName);
                        fname = openFileDialog1.FileName;
                        using (myStream)
                        {
                            this.SecondImage = new Bitmap(myStream);
                            this.inputImage2_pictureBox1.Image = this.SecondImage;
                        }
                    }
                }
                catch (Exception ex)
                {
                    MessageBox.Show("Error: Could not read file from disk. Original error: " + ex.Message);
                }
            }
        }

        private void button1_Click(object sender, EventArgs e)
        {
            var buffersOfFirstImage = BuffersFirstImage;

            int width = buffersOfFirstImage.Width;
            int height = buffersOfFirstImage.Height;
            int imageSize = width * height;

            sobel(buffersOfFirstImage.RedChannel, buffersOfFirstImage.GreenChannel, height, width, imageSize, 'x');
            sobel(buffersOfFirstImage.RedChannel, buffersOfFirstImage.BlueChannel, height, width, imageSize, 'y');
            var outputbuffer = ImageHelper.CreateNewImageBuffersObject(buffersOfFirstImage.GreenChannel, buffersOfFirstImage.GreenChannel, buffersOfFirstImage.GreenChannel, width, height);
            var outputBuffersObject = ImageHelper.CreateNewImageBuffersObject(buffersOfFirstImage.BlueChannel, buffersOfFirstImage.BlueChannel, buffersOfFirstImage.BlueChannel, width, height);
            for (int i = 0; i < outputBuffersObject.GreenChannel.Length; i++)
            {
                outputBuffersObject.GreenChannel[i] = (int)Math.Sqrt((Math.Pow(outputBuffersObject.GreenChannel[i], 2) + (Math.Pow(outputbuffer.BlueChannel[i], 2))));
                //outputBuffersObject.GreenChannel[i] = outputBuffersObject.GreenChannel[i] %255;
                if (outputBuffersObject.GreenChannel[i] > 255)
                     outputBuffersObject.GreenChannel[i] = 255;
                else if (outputBuffersObject.GreenChannel[i] < 70)
                     outputBuffersObject.GreenChannel[i] = 0;
            }
            this.outputImage_pictureBox.Image = (Bitmap)ImageHelper.GetImageFromBuffers(outputBuffersObject).BitmapObject;



        }
       

        private void button2_Click(object sender, EventArgs e)
        {

            var bufferOfSecondImage = BuffersSecondImage;
            int width = bufferOfSecondImage.Width;
            int height = bufferOfSecondImage.Height;
            int imageSize = width * height;
            histo(bufferOfSecondImage.RedChannel, imageSize);
            histo(bufferOfSecondImage.GreenChannel, imageSize);
            histo(bufferOfSecondImage.BlueChannel, imageSize);
            double x = (double)255 / imageSize;
            double m = bufferOfSecondImage.BlueChannel.Max();
            m = m * x;
            for (int i = 0; i < bufferOfSecondImage.BlueChannel.Length; i++)
            {
                bufferOfSecondImage.GreenChannel[i] = (int)(bufferOfSecondImage.GreenChannel[i] * x);
                bufferOfSecondImage.BlueChannel[i] = (int)(bufferOfSecondImage.BlueChannel[i] * x);
                bufferOfSecondImage.RedChannel[i] = (int)(bufferOfSecondImage.RedChannel[i] * x);
            }

            var outputBuffersObject = ImageHelper.CreateNewImageBuffersObject(bufferOfSecondImage.RedChannel, bufferOfSecondImage.GreenChannel, bufferOfSecondImage.BlueChannel, width, height);
            this.outputImage_pictureBox.Image = (Bitmap)ImageHelper.GetImageFromBuffers(outputBuffersObject).BitmapObject;
           
           
            


        }
        void fn(ImageBuffers x) {

            var buffersOfFirstImage = BuffersFirstImage;

            int width = buffersOfFirstImage.Width;
            int height = buffersOfFirstImage.Height;
            int imageSize = width * height;

            sobel(buffersOfFirstImage.RedChannel, buffersOfFirstImage.GreenChannel, height, width, imageSize, 'x');
            sobel(buffersOfFirstImage.RedChannel, buffersOfFirstImage.BlueChannel, height, width, imageSize, 'y');
            var outputbuffer = ImageHelper.CreateNewImageBuffersObject(buffersOfFirstImage.GreenChannel, buffersOfFirstImage.GreenChannel, buffersOfFirstImage.GreenChannel, width, height);
            var outputBuffersObject = ImageHelper.CreateNewImageBuffersObject(buffersOfFirstImage.BlueChannel, buffersOfFirstImage.BlueChannel, buffersOfFirstImage.BlueChannel, width, height);
            for (int i = 0; i < outputBuffersObject.GreenChannel.Length; i++)
            {
                outputBuffersObject.GreenChannel[i] = (int)Math.Sqrt((Math.Pow(outputBuffersObject.GreenChannel[i], 2) + (Math.Pow(outputbuffer.BlueChannel[i], 2))));
                outputBuffersObject.GreenChannel[i] = outputBuffersObject.GreenChannel[i] % 255;
            }
            this.outputImage_pictureBox.Image = (Bitmap)ImageHelper.GetImageFromBuffers(outputBuffersObject).BitmapObject;

        
        }
    }
}
