package nr339.lexer;

%%

%public
%class XiLexer
%type Token
%function nextToken

%unicode
%pack
%line
%column

%{
	// different possible types of tokens
    enum TokenType {
		ID,
		INT,
		CHAR,
		STRING,
		SYMBOL,
		KEYWORD,
		ERROR
    }
	// represents the string or character that will be built
	private StringBuffer string = new StringBuffer();  
	// temporary token to get correct column number before evaluating
	private Token tempToken; 
	// represents the previous state we were in (for strings and chars)
	private int prevState = -1;
	private final String maxint = "9223372036854775808";
	/**
	 * Token class to be returned by the lexer. Contains the type of token,
	 * attributes for ints, chars, strings, and errors. Also has location 
	 * information and a flag to be set if an int token is 2^63.
	 */
    class Token {
		TokenType type;
		Object attribute;
		int line;
		int col;
		boolean maxIntFlag;
		Token(TokenType tt) {
			type = tt; 
			attribute = null; 
			line = yyline+1; 
			col = yycolumn+1;
			maxIntFlag = false;
		}
		Token(TokenType tt, Object attr) {
			type = tt; attribute = attr; 
			line = yyline+1; col = yycolumn+1;
			maxIntFlag = false;
		}
		Token(TokenType tt, Object attr, boolean b) {
			type = tt; attribute = attr;
			line = yyline+1; col = yycolumn+1;
			maxIntFlag = b;
		}

		public String toString() {
			return "" + line + ":" + col + " " + type + "(" + attribute + ")";
		}
    }
	/**
	 * Parses a string representing a hex value to the character corresponding
	 * to that ASCII value.
	 *
	 * @param hexString The string to be parsed
	 * @return The character with the ASCII value corresponding to the input,
	 * "ERROR" otherwise
	 */
	private String parseHex(String hexString){
		int hexVal = Integer.parseInt(hexString, 16);
		return Character.toString((char) hexVal);
	}

	/**
	 * Converts an escaped letter to its corresponding escape sequence (e.g. n -> \n)  
	 *
	 * @param escapeLetter The letter to be escaped
	 * @return The escaped version of the given letter, if it is a valid letter, otherwise "ERROR"
	 */
	private String getEscapedChar(String escapeLetter){
		switch(escapeLetter){
			case "n":
				return "\n";
			case "b":
				return "\b";
			case "t":
				return "\t";
			case "\"":
				return "\"";
			case "'":
				return "'";
			case "f":
				return "\f";
			case "r":
				return "\r";
			case "\\":
				return "\\";
			default:
				return "ERROR";
		}
	}
%}

Keyword = "int" | "use" | "bool" | "return" | "true" | "false" | 
		  "if" | "else" | "while" | "length"
Whitespace = [ \t\f\r\n]
Letter = [a-zA-Z]
Digit = [0-9]
HexDigit = [0-9a-fA-F]
EscapeChars = (n|b|r|t|f|\"|'|\\)
Identifier = {Letter}({Digit}|{Letter}|_|')*
Integer = "0"|[1-9]{Digit}*
Symbol = "*>>" | "<=" | ">=" | "==" | "!=" | "!" | "*" | ">" | "<" | "=" | "+" | 
		 "-" | "/" | "%" | "&" | "|" | "(" | ")" | "[" | "]" | "{" | "}" | ":" | 
		 "," | ";" | "_"
Comment = "//"[^\r\n]*

%state STRING
%state CHAR
%state ESCAPE
%state HEX
%state DEATH

%%
<YYINITIAL> {
	"\""		{
					prevState = YYINITIAL; yybegin(STRING); 
					tempToken = new Token(TokenType.STRING);
				}
	'			{
					prevState = YYINITIAL; 
					yybegin(CHAR); 
					tempToken = new Token(TokenType.CHAR);
				}
	{Whitespace} { /* ignore */ }
	{Comment} 	{ /* ignore */ }
	{Integer}   { 
					try {
						return new Token(TokenType.INT,
							Long.parseLong(yytext()));
			  		}
					catch (NumberFormatException e) {
						if (yytext().equals(maxint))
							// stores int as a string
							return new Token(TokenType.INT, yytext(), true);
						else
							yybegin(DEATH);
						return new Token(TokenType.ERROR, "Integer too large");
					}
				}			
	{Keyword}	{ return new Token(TokenType.KEYWORD, yytext()); }
	{Identifier} { return new Token(TokenType.ID, yytext()); }
	{Symbol} 	{ return new Token(TokenType.SYMBOL, yytext()); }
}
<STRING> {
	"\""        {
					String ret = string.toString();
					string.setLength(0); // clear the string buffer 
					tempToken.attribute = ret;
					prevState = STRING;
					yybegin(YYINITIAL);
					return tempToken;
				}
	"\\"		{ prevState = STRING; yybegin(ESCAPE); }

	[^\"]       { string.append(yytext()); }

	<<EOF>>		{
					yybegin(DEATH); 
					tempToken.type = TokenType.ERROR; 
					tempToken.attribute = "Incomplete string"; 
					return tempToken;
				}
}
<CHAR> {
	"\\"        { prevState = CHAR; yybegin(ESCAPE); }
	[^'\\]'		{
					// make sure there is no additional character 
					// after escape sequence
					if(tempToken.attribute != null){
						yybegin(DEATH); 
						tempToken.type = TokenType.ERROR;
						tempToken.attribute = "Invalid character literal";
						return tempToken; 
					}
					tempToken.attribute = yytext().charAt(0);
					string.setLength(0); 
					yybegin(YYINITIAL); 
					return tempToken;
				}
	'			{
					// only valid if we find it after an escape sequence
					if(tempToken.attribute == null){
						yybegin(DEATH); 
						tempToken.type = TokenType.ERROR;
						tempToken.attribute = "Invalid character literal";
						return tempToken; 
					}
					tempToken.attribute = tempToken.attribute.toString().charAt(0);
					string.setLength(0); 
					yybegin(YYINITIAL); return tempToken;
				}
	<<EOF>>		{
					yybegin(DEATH); 
					tempToken.type = TokenType.ERROR; 
					tempToken.attribute = "Incomplete character"; 
					return tempToken;
				}
	[^]			{
					yybegin(DEATH); 
					tempToken.type = TokenType.ERROR; 
					tempToken.attribute = "Invalid character literal"; 
					return tempToken;
				}

}
<ESCAPE> {
	{EscapeChars}	{
						string.append(getEscapedChar(yytext()));
						tempToken.attribute = string.toString();
						yybegin(prevState);
					}
	x 				{ yybegin(HEX); }
	[^]				{
						yybegin(DEATH); 
						return new Token(TokenType.ERROR, 
							"Invalid escape sequence");
					}
}
<HEX>{
	{HexDigit}{HexDigit}	{
								String character = parseHex(yytext());
								if(character == "ERROR"){
									yybegin(DEATH);
									return new Token(TokenType.ERROR, 
										"Invalid hex value");
								}
								string.append(character);
								tempToken.attribute = string.toString();
								yybegin(prevState);
							}	 
	[^]						{
								yybegin(DEATH); 
								return new Token(TokenType.ERROR, 
									"Must be a hex value");
							}
}
<DEATH>{
	[^]	{ /* do nothing */ }
}

[^]		{ 
			yybegin(DEATH); 
			return new Token(TokenType.ERROR, "Invalid token"); 
		} // if nothing else matches, go to error
