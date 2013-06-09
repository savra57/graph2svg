package com.googlecode.graph2svg.tools.jrav;

import java.io.File;
import java.io.IOException;

import org.iso_relax.verifier.Schema;
import org.iso_relax.verifier.Verifier;
import org.iso_relax.verifier.VerifierConfigurationException;
import org.iso_relax.verifier.VerifierFactory;
import org.xml.sax.SAXException;
import org.xml.sax.SAXParseException;

import com.googlecode.graph2svg.tools.fileFilter.RegExpFileFilter;

/**
 * Universal XML schema validator.
 */
public class BatchValidator {

	public static void main(String[] args) throws VerifierConfigurationException, SAXException, IOException {
		try
		{
			// create a VerifierFactory
			VerifierFactory factory = new com.sun.msv.verifier.jarv.TheFactoryImpl();

			if (args.length < 2) {
				printUsage();
				return;
			}

			String schemaFileName = args[0]; // "xygr.rng" or xygr.dtd;

			// compile a RELAX schema (or whatever schema you like)
			File schemaFile = new File(schemaFileName);
			Schema schema = factory.compileSchema(schemaFile);

			// obtain a verifier
			Verifier verifier = schema.newVerifier();
			MyErrorHandler myErrorHandler = new MyErrorHandler(schemaFile.getName());
			verifier.setErrorHandler(myErrorHandler);

			// the file to validate or a directory with xml files
			String fileName = args[1];

			File file = new File(fileName);

			if (file.isDirectory()) {
				String filterString;
				if (args.length >= 3) {
					filterString = args[2];
				} else {
					filterString = ".*\\.xml"; // default
				}
				File[] fileList = file.listFiles(new RegExpFileFilter(filterString));
				for (File f : fileList) {

					// this has to be called because of some bug in the verifier
					// causing that error messages of a second invalid XML file
					// in a row are not recored
					verifier = schema.newVerifier();
					verifier.setErrorHandler(myErrorHandler);

					myErrorHandler.reset();
					verifyFile(verifier, f);
					myErrorHandler.printMessages();
				}
			} else {
				verifyFile(verifier, file);
				myErrorHandler.printMessages();
			}

		} catch (Exception e) {
			System.out.println("Exception running validator: " + e);
		}
	}

	private static void verifyFile(Verifier verifier, File xmlFile) throws SAXException, IOException {
		System.out.print(xmlFile + ": ");
		try {
			if (verifier.verify(xmlFile)) {
				System.out.println(" ... ok");
			} else {
				System.out.println(" ... NOT VALID");
			}
		} catch (SAXParseException e) {
			System.out.println(" ... exception during validation - NOT VALID");
		}
	}

	private static void printUsage() {
		System.out.println("Two or tree arguments are expected:");
		System.out
				.println("\n   schemaFile - validation schema"
						+ "\n   xmlFileDir - directory where xml files are"
						+ "\n   filter - regEx filter string - optional, defaul: '.*\\.xml'");
	}

}
