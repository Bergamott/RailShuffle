import java.awt.*;import java.awt.image.*;import java.awt.event.*;import java.io.*;import java.awt.Color;import java.awt.Graphics2D;import java.awt.image.BufferedImage;import javax.imageio.ImageIO;import javax.imageio.ImageWriter;import javax.imageio.ImageWriteParam;import javax.imageio.IIOImage;import javax.imageio.stream.ImageOutputStream;import javax.swing.JFileChooser;import javax.swing.filechooser.*;import java.util.*;import java.io.File;import java.io.FileOutputStream;import java.io.FileInputStream;import java.awt.geom.AffineTransform;// Makes larger image into iOS iconspublic class makeicons{	public static void main(String args[])	{		BufferedImage m_original;		int w,h;		int i,j,k,l,m,n;		int r,g,b,a,s;		int inPix[];		int halfPix[];		int factor=2;//		String outNames[]={"Icon.png","Icon@2x.png","Icon-72.png",//			"Icon-Small-50.png","Icon-Small.png","Icon-Small@2x.png",//			"Icon-Small-50@2x.png","Icon-72@2x.png"};
		String outNames[]={"Icon-29@2x.png", "Icon-29@3x.png", 			"Icon-40.png", "Icon-40@2x.png",
			"Icon-60@2x.png", "Icon-60@3x.png", "Icon-76.png",
			"Icon-76@2x.png","Icon-83.5@2x.png"};//		int outSizes[]={57,114,72,50,27,54,100,144};
		int outSizes[]={58,87,40,80,120,180,76,152,167};		try{			if (args.length==1)			{				m_original=ImageIO.read(new FileInputStream(args[0]));				w=m_original.getWidth();				h=m_original.getHeight();								for (i=0;i<outNames.length;i++)				{					Image tempB = m_original.getScaledInstance(outSizes[i],outSizes[i],Image.SCALE_AREA_AVERAGING);					BufferedImage tempB2 = new BufferedImage(outSizes[i], outSizes[i], BufferedImage.TYPE_INT_RGB);					Graphics2D tempG = tempB2.createGraphics();					tempG.drawImage(tempB,0,0,null);					savePng(tempB2,outNames[i]);					tempG.dispose();				}			}			else				System.out.println("Usage: java makeicons bigfile.png");		}		catch(Exception e){e.printStackTrace();}	}		public static void savePng(BufferedImage bI, String nam)	{		try{			Iterator iterator = ImageIO.getImageWritersBySuffix("png");			if (! iterator.hasNext())			{				throw new IllegalStateException("no writers found");			}			ImageWriter iw = (ImageWriter)iterator.next();			FileOutputStream os = new FileOutputStream(nam);			ImageOutputStream ios = ImageIO.createImageOutputStream(os);			iw.setOutput(ios);			ImageWriteParam iwp = iw.getDefaultWriteParam();			iw.write(bI);			System.out.println("Saved "+nam);		}catch(Exception e){e.printStackTrace();}	}}