package com.googlecode.graph2svg.tools.comparison;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

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

			String outputFileStr = args[0];
			String generatedSubdirStr = args[1]; 
			String templatesSubdirStr = args[2]; 

			File outputFile = new File(outputFileStr);
			System.out.print("Output file: " + outputFile.getAbsolutePath());
			
			File baseDir = outputFile.getParentFile();
			
			outputWriter = new FileWriter(outputFile);

			File generatedDir = new File(baseDir, generatedSubdirStr);
			if (generatedDir.isDirectory()) {
				String filterString;
				if (args.length >= 4) {
					filterString = args[3];
				} else {
					filterString = ".*\\.svg"; // default
				}
				File[] fileList = generatedDir.listFiles(new RegExpFileFilter(filterString));
				printHeader(outputWriter);
				for (File f : fileList) {
					String leftSVG = creteFilePath(f.getName(), generatedSubdirStr);
					String rightSVG = creteFilePath(f.getName(), templatesSubdirStr);
					printRow(outputWriter, leftSVG, rightSVG);
				}
				printFooter(outputWriter);
			} else {
				System.out.println(generatedDir.getAbsolutePath() + "is not a directory");
			}

			System.out.println(" ... done \n \t" + outputFileStr + " created");

		} finally {
			if (outputWriter != null)
				outputWriter.close();
		}
	}

	private static String creteFilePath(String path, String templatesSubdir) {
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
		System.out.println("\n   outputFile - output file (html), its parent dir used as baseDir"
						+ "\n   generatedSubdir - a subdirectory of baseDir where new svg files are"
						+ "\n   templatesSubdir - a subdirectory of baseDir where templates (old) svg files are"
						+ "\n   filter - regEx filter string - optional, defaul: '.*\\.svg'");
	}

}
