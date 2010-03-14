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


public class BatchSaxonTransform {
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
		String outExtension;
		outExtension = args[2];
		
		
		File file = new File(fileName);

		if (file.isDirectory()) {
			String filterString;
			if (args.length >= 4) {
				filterString = args[3];
			} else {
				filterString = ".*\\.xml"; // default
			}
			File[] fileList = file.listFiles(new RegExpFileFilter(filterString));
			for (File f : fileList) {
				transformFile(templates, f, outExtension);
			}
		} else {
			transformFile(templates, file, outExtension);
		}

		// check the validity of a DOM.

		// or you can pass an Element to validate that subtree.
		// Element e = (Element)dom.getDocumentElement().getFirstSibling();
		// if( verifier.verify(e) )
		// ...
	}

	private static void transformFile(Templates templates, File sourceFile, String outExtension) throws SAXException, IOException {
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
		
		File resultFile = new File(replaceExtension(sourceFile.getAbsolutePath(), outExtension)); 
		Result result = new StreamResult(resultFile);
		
		try {
			transformer.transform(source, result);
		} catch (TransformerException e) {
			System.out.println(" ... TRANSFORMATION ERROR: " + e.getMessageAndLocation() );
		}
		System.out.println();
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
		System.out.println("Tree or four arguments are expected:");
		System.out
				.println("\n   style - a xslt transformation file"
						+ "\n   xmlFileDir - xml file or directory where xml files are"
						+ "\n   outputExtension - extension used for output files"
						+ "\n   filter - regEx filter string - optional, defaul: '.*\\.xml'");
	}

}
