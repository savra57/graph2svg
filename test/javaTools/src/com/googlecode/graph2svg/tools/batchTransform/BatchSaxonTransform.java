package com.googlecode.graph2svg.tools.batchTransform;

import java.io.File;
import java.io.IOException;

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



public class BatchSaxonTransform 
{
	private static String outExtension = "";
	private static File outputDir;
	
	public static void main(String[] args) throws  SAXException, IOException {

		if (args.length < 2) {
			printUsage();
			return;
		}
		

		String style = args[0]; // "xygr.rng";
//		
		System.out.println("Using XSLT style: " + style);
		TransformerFactory factory = TransformerFactory.newInstance();
		
		factory.setErrorListener(new MyErrorListener());
		Templates templates;
		try {
			templates = factory.newTemplates(new StreamSource(new File(style)));
		} catch (TransformerConfigurationException e) {
			// should not reache there
			e.printStackTrace();
			return;
		}
		
    	String fileName = args[1]; // single xml file to transform or directory;
		outExtension = args[2];
		
		String filterString = ".*\\.xml"; // default
		String outputDirString = null;
		if (args.length >= 4) {
			outputDirString = args[3];
			
			if (args.length >= 5) {
				filterString = args[4];
			} 
		} 
		
		
		File file = new File(fileName);
		
		

		if (file.isDirectory()) {
			outputDir = getOutputDir(file, outputDirString);
			File[] fileList = file.listFiles(new RegExpFileFilter(filterString));
			for (File f : fileList) {
				if (f.isFile()) {
					transformFile(templates, f);
				}
			}
		} else {
			outputDir = getOutputDir(file.getParentFile(), outputDirString);
			transformFile(templates, file);
		}

		// check the validity of a DOM.

		// or you can pass an Element to validate that subtree.
		// Element e = (Element)dom.getDocumentElement().getFirstSibling();
		// if( verifier.verify(e) )
		// ...
	}


	private static void transformFile(Templates templates, File sourceFile) throws SAXException, IOException {
		Transformer transformer;
		try {
			transformer = templates.newTransformer();
		} catch (TransformerConfigurationException e) {
			// should not reache there
			e.printStackTrace();
			return;
		}
		
		if (transformer == null) {
			return;
		}
		//TODO is not used, why???
		transformer.setErrorListener(new MyErrorListener());

		System.out.print(sourceFile + ": ");
		Source source = new StreamSource(sourceFile);
		
		File outFile = getOutputFile(sourceFile); 
		Result result = new StreamResult(outFile);
		
		try {
			transformer.transform(source, result);
		} catch (TransformerException e) {
			System.out.println(" ... TRANSFORMATION ERROR: " + e.getMessageAndLocation() );
		}
		System.out.println();
	}
	

	private static File getOutputDir(File baseDir, String outputDirString) {
		if (outputDirString == null) {
			return baseDir;
		} else {
			File outDir = new File(baseDir, outputDirString);
			outDir.mkdirs();
			return outDir;
		}
	}
	
	private static File getOutputFile(File sourceFile) {
		String outFileName = replaceExtension(sourceFile.getName(), outExtension);
		return new File(outputDir, outFileName);
	}

	private static String replaceExtension(String absolutePath, String newExtension) {
		int lastIndex = absolutePath.lastIndexOf('.');
		if (lastIndex == -1) {
			return absolutePath + "." + newExtension;
		} else {
			return absolutePath.substring(0, lastIndex + 1) + newExtension;
		}
	}

	private static void printUsage() {
		System.out.println("3, 4 or 5 arguments expected:");
		System.out.println("\n   style - a xslt transformation file"
						+ "\n   xmlFileDir - xml file or directory where xml files are"
						+ "\n   outputExtension - extension used for output files"
						+ "\n   outputDir - output directory relative to input - optional, default '.'"
						+ "\n   filter - regEx filter string - optional, defaul: '.*\\.xml'"
						);
	}

}
