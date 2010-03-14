package com.googlecode.graph2svg.tools.comparison;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.OutputStream;

import javax.xml.transform.Result;
import javax.xml.transform.Source;
import javax.xml.transform.Templates;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import org.xml.sax.SAXException;

import com.googlecode.graph2svg.tools.fileFilter.RegExpFileFilter;


public class CreateComparison {
	private static final int PICTURE_WIDTH = 420;



	public static void main(String[] args) throws SAXException, IOException {
		FileWriter outputWriter = null;
		try {
			if (args.length < 3) {
				printUsage();
				return;
			}

			String inputDirStr = args[0]; // "xygr.rng";
			//		
			System.out.print("Processing files from: " + inputDirStr);

			String templatesSubdir = args[1]; // single xml file to transform
												// or directory;
			String outputFileStr = args[2];

			

			

			File inputDir = new File(inputDirStr);
			
			File outputFile = new File(inputDir, outputFileStr);
			outputWriter = new FileWriter(outputFile);

			if (inputDir.isDirectory()) {
				String filterString;
				if (args.length >= 4) {
					filterString = args[3];
				} else {
					filterString = ".*\\.svg"; // default
				}
				File[] fileList = inputDir.listFiles(new RegExpFileFilter(filterString));
				printHeader(outputWriter);
				for (File f : fileList) {
					String leftSVG = f.getName();
					String rightSVG = creteTemplateFilePath(f.getName(), templatesSubdir);
					printRow(outputWriter, leftSVG, rightSVG);
				}
				printFooter(outputWriter);
			} else {
				System.out.println(inputDir.getAbsolutePath() + "is not a directory");
			}

			System.out.println(" ... done \n \t" + outputFileStr + " created");

		} finally {
			outputWriter.close();
		}
	}

	private static String creteTemplateFilePath(String path, String templatesSubdir) {
		int lastIndex = path.lastIndexOf('/');
		String dirDelim = "/";
		if (lastIndex == -1) {
			lastIndex = path.lastIndexOf('\\');
			dirDelim = "\\";
		}
		if (lastIndex == -1) {
			return templatesSubdir + "/" + path;
		} else {
			return path.substring(0, lastIndex + 1) + templatesSubdir +
				dirDelim + path.substring(lastIndex + 1);
		}
	}

	private static void printHeader(FileWriter ow) throws IOException {
		ow.write("<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">\n");
		ow.write("<html>\n");
		ow.write("<head>\n");
		ow.write("  <meta http-equiv=\"Content-Type\" content=\"text/html; charset=windows-1250\">\n");
		ow.write("  <title>SVG comare</title>\n");
		ow.write("</head>\n");
		ow.write("<body>\n");
		ow.write("<table cellpadding=\"10\">\n");
	}
	
	
	private static void printRow(FileWriter ow, String leftSVG, String rightSVG) throws IOException {
		ow.write("  <tr>\n");
		printCell(ow, leftSVG);
		printCell(ow, rightSVG);
		ow.write("  </tr>\n");
	}

	
	private static void printCell(FileWriter ow, String svgFileName) throws IOException {
		ow.write("    <td>" + svgFileName + "</br><object data=\"" + svgFileName + "\"" +
				" width=\"" + PICTURE_WIDTH + "\"  type=\"image/svg+xml\" /></td>\n");
	}

	private static void printFooter(FileWriter ow) throws IOException {
		ow.write("</table>\n");
		ow.write("</body>\n");
		ow.write("</html>\n");

		
	}

	private static void printUsage() {
		System.out.println("Tree or four arguments are expected:");
		System.out
				.println("\n   inputDir - a directory where new svg files are"
						+ "\n   templatesSubdir - subdirectory of inputDir wher templates (old) svg files are"
						+ "\n   outputFile - output file (html)"
						+ "\n   filter - regEx filter string - optional, defaul: '.*\\.svg'");
	}

}
