package com.googlecode.graph2svg.tools.batchTransform;

import javax.xml.transform.ErrorListener;
import javax.xml.transform.TransformerException;

class MyErrorListener implements ErrorListener {
	public void fatalError(TransformerException e) throws TransformerException {
		printException("FATAL ERROR", e);
	}

	public void error(TransformerException e) throws TransformerException {
		printException("ERROR", e);
	}

	public void warning(TransformerException e) {
		printException("WARNING", e);
	}
	
	private void printException(String prefix, TransformerException e) {
		System.out.print("\n    " + e.getMessageAndLocation());
	}
}