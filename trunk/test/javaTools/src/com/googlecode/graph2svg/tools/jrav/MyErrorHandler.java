package com.googlecode.graph2svg.tools.jrav;

import java.util.ArrayList;
import java.util.List;

import org.xml.sax.ErrorHandler;
import org.xml.sax.SAXException;
import org.xml.sax.SAXParseException;

class MyErrorHandler implements ErrorHandler {

	private List<String> messages = new ArrayList<String>();
	private String validationType = "";

	public MyErrorHandler(String type) {
		validationType = type + ": ";
	}

	public void fatalError(SAXParseException e) throws SAXException {
		addMessage("FATAL ERROR", e);
	}

	public void error(SAXParseException e) throws SAXException {
		addMessage("ERROR", e);
	}

	public void warning(SAXParseException e) {
		addMessage("WARNING", e);
	}

	private void addMessage(String prefix, SAXParseException e) {
		String message = validationType + prefix + " (line: "
				+ e.getLineNumber() + ", col: " + e.getColumnNumber() + "): "
				+ e;
		messages.add(message);
	}

	public void reset() {
		messages.clear();
	}

	public void printMessages() {
		for (String message : messages) {
			System.out.println("   " + message);
		}
	}

	public boolean hasMessages() {
		return !messages.isEmpty();
	}
}
