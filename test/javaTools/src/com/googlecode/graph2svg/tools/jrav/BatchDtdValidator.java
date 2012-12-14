package com.googlecode.graph2svg.tools.jrav;

import java.io.File;
import java.io.FileInputStream;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerFactory;

import org.w3c.dom.Document;

import com.googlecode.graph2svg.tools.fileFilter.RegExpFileFilter;

public class BatchDtdValidator {

	public static void main(String[] args) throws ParserConfigurationException,
			TransformerConfigurationException {
		if (args.length < 2) {
			printUsage();
			return;
		}

		String dtdSchema = args[0];

		DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
		factory.setValidating(true);
		DocumentBuilder builder = factory.newDocumentBuilder();

		MyErrorHandler myErrorHandler = new MyErrorHandler("DTD");
		builder.setErrorHandler(myErrorHandler);

		TransformerFactory tf = TransformerFactory.newInstance();
		Transformer transformer = tf.newTransformer();

		transformer.setOutputProperty(OutputKeys.DOCTYPE_SYSTEM, dtdSchema);

		String fileName = args[1];
		File file = new File(fileName);

		if (file.isDirectory()) {
			String filterString;
			if (args.length >= 3) {
				filterString = args[2];
			} else {
				filterString = ".*\\.xml"; // default
			}
			File[] fileList = file
					.listFiles(new RegExpFileFilter(filterString));
			for (File f : fileList) {
				verifyFile(builder, transformer, myErrorHandler, f);
				myErrorHandler.printMessages();
				myErrorHandler.reset();
			}
		} else {

			verifyFile(builder, transformer, myErrorHandler, file);
			myErrorHandler.printMessages();
		}

	}

	private static void verifyFile(DocumentBuilder builder,
			Transformer transformer, MyErrorHandler myErrorHandler, File file) {
		System.out.print(file + ": ");
		try {

			Document xmlDocument = builder.parse(new FileInputStream(file));
			// DOMSource source = new DOMSource(xmlDocument);
			// StreamResult result = new StreamResult(System.out);
			//
			// transformer.transform(source, result);
			if (myErrorHandler.hasMessages()) {
				System.out.println(" ... ok");
			} else {
				System.out.println(" ... NOT VALID");
			}
		} catch (Exception e) {
			System.out.println(" ... NOT VALID - exception: " + e.getMessage());
			e.printStackTrace();
		}
	}

	private static void printUsage() {
		System.out.println("Two or tree arguments are expected:");
		System.out
				.println("\n   schemFile - a DTD schema"
						+ "\n   xmlFileDir - directory where xml files are"
						+ "\n   filter - regEx filter string - optional, defaul: '.*\\.xml'");
	}

}