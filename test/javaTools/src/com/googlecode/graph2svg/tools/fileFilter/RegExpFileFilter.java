package com.googlecode.graph2svg.tools.fileFilter;

import java.io.File;
import java.io.FilenameFilter;
import java.util.regex.Pattern;

public class RegExpFileFilter implements FilenameFilter {
	private String m_strPattern = null;

	private Pattern m_regexPattern;

	public RegExpFileFilter(String p_strPattern) {
		m_strPattern = p_strPattern;
		m_regexPattern = Pattern.compile(m_strPattern);
	}

	public boolean accept(File m_directory, String m_filename) {
		if (m_regexPattern.matcher(m_filename).matches())
			return true;

		return false;

	}

}