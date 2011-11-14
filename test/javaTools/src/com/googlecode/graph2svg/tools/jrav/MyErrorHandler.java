package com.googlecode.graph2svg.tools.jrav;

import org.xml.sax.ErrorHandler;
import org.xml.sax.SAXException;
import org.xml.sax.SAXParseException;

class MyErrorHandler implements ErrorHandler{
	public void fatalError(SAXParseException e) throws SAXException {
		printException("FATAL ERROR", e);
	}

	public void error(SAXParseException e) throws SAXException {
		printException("ERROR", e);
	}

	public void warning(SAXParseException e) {
		printException("WARNING", e);
	}
	
	private void printException(String prefix, SAXParseException e) {
		System.out.print("\n    " + prefix + 
				" (line: " + e.getLineNumber() + ", col: " + e.getColumnNumber() + "): " + e);
	}
}
