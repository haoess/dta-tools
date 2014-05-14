import java.io.*;

/**
 * This program builds simple wiki pages from test files.
 *
 * Created by binder on 07.05.14.
 */
public class WikiBuilder {
    static String stylesheetsFN;
    static String nl = "\r\n";

    public static void main(String[] args) {
        // path to the test file ("tag.t")
        String testFN = args[0];
        System.out.println("use test file: "+testFN);
        // folder which contains /t/xml
        stylesheetsFN = args[1];
        System.out.println("contains /t/xml: "+stylesheetsFN);
        String outFN = args[2];
        System.out.println("write output to " + outFN);
        boolean writeSeparatorLine = false;
        try {
            BufferedReader in = new BufferedReader(new FileReader(testFN));
            BufferedWriter out = null;
            String line;
            while ((line = in.readLine()) != null) {
                try {
                    if (line.startsWith("#---")) {
                        out = readFileBreak(line, outFN);
                        writeSeparatorLine = false;
                    } else if (line.startsWith("##")) {
                        readCaption(out, line);
                        writeSeparatorLine = false;
                    } else if (line.startsWith("#")) {
                        if (writeSeparatorLine) {
                            out.write("-" + nl);
                            writeSeparatorLine = false;
                        }
                        readComment(out, line);
                    } else if (line.startsWith("like")) {
                        if (writeSeparatorLine) {
                            out.write("-" + nl);
                        }
                        readTest(in, out, line);
                        writeSeparatorLine = true;
                    }
                }catch(NullPointerException e){
                    System.out.println("ERROR: no initial filename found! (has to be marked by '#--- <filename>'");
                    e.printStackTrace();
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private static BufferedWriter readFileBreak(String currentLine, String path) throws IOException {
        return new BufferedWriter(new FileWriter(path + File.separator + currentLine.substring(5).trim().replaceAll(" ","-")+".md"));
    }

    private static void readCaption(BufferedWriter out, String currentLine) throws IOException {
        out.write(commentHTML(currentLine) + nl);
        out.flush();
    }

    private static void readComment(BufferedWriter out, String currentLine) throws IOException {
        out.write(commentHTML(currentLine.substring(2)) + nl);
        out.flush();
    }

    private static void readTest(BufferedReader in, BufferedWriter out, String currentLine) throws IOException {
        String tmp = currentLine;
        int minTabCount = Integer.MAX_VALUE;
        int currTabCount;
        String line;
        while (!(tmp.trim() + "\n").contains(");\n") && (line = in.readLine()) != null) {
            //currTabCount = getCharCountFromStart('\t', line);
            //System.out.println(currTabCount);
            //if(currTabCount < minTabCount){
            //    minTabCount = currTabCount;
            //}
            tmp += nl + line;
        }
        //System.out.println(tmp);
        //tmp = tmp.replaceFirst("\t{"+minTabCount+"}","").replaceAll("\n\t{"+minTabCount+"}","\n");

        //System.out.println(minTabCount);
        //System.out.println(tmp);
        //out.write("input:" + nl);
        out.write("```xml" + nl);
        String input = getXML(stylesheetsFN + File.separator + getFileName(tmp));
        out.write(correctIndent(cleanNewLines(input)) + nl);
        out.flush();
        out.write("```" + nl);
        out.write("output:" + nl);
        out.write("```xml" + nl);
        //System.out.println(cleanNewLines(clearHTML(getHTML(tmp))));
        //System.out.println();
        out.write(correctIndent(cleanNewLines(clearHTML(getHTML(tmp)))) + nl);
        out.flush();
        out.write("```" + nl);
        out.flush();
    }

    private static int getCharCountFromStart(char chr, String str){
        for (int i = 0; i < str.length(); i++) {
            if(str.charAt(i)!=chr){
                return i;
            }
        }
        return str.length();
    }

    private static String correctIndent(String str){
        String[] lines = str.split(nl);
        String result = "";
        int minTabCount = Integer.MAX_VALUE;
        int currTabCount;
        for(String line: lines) {
            currTabCount = getCharCountFromStart('\t', line);
            //System.out.println(currTabCount);
            if (currTabCount < minTabCount) {
                minTabCount = currTabCount;
            }
        }
        for(String line: lines) {
           result += nl + line.replaceFirst("\t{"+minTabCount+"}","");
        }
        return result.replaceFirst(nl, "");
    }

    private static String getFileName(String test) {
        return test.split("'")[1];
    }

    private static String getHTML(String test) {
        return test.split("[{}]")[1];
    }

    private static String clearHTML(String html) {
        return html.replaceAll("\\\\s[*+]", " ").replaceAll("\\\\\\[", "[").replaceAll("\\\\\\]", "]").replaceAll("\\\\\\(", "(").replaceAll("\\\\\\)", ")").replaceAll("\\[ \\]", " ");
    }

    private static String commentHTML(String html) {
        return html.replaceAll("<", "\\\\<").replaceAll(">", "\\\\>");

    }

    private static String getXML(String xmlFN) throws IOException {
        BufferedReader in = new BufferedReader(new FileReader(xmlFN));
        String line;
        String xml = "";
        while ((line = in.readLine()) != null) {
            xml += line + nl;
        }
        if (xml.contains("<front>") && xml.contains("<body>")) {
            return xml.split("</?text>")[1];
        }
        if (xml.contains("<body>")) {
            return xml.split("</?body>")[1];
        }
        if (xml.contains("<front>")) {
            return xml.split("</?front>")[1];
        }
        return "error";
    }

    private static String cleanNewLines(String input) {
        int start = 0;
        int end = input.length() - 1;
        while (start < input.length() && "\r\n".contains("" + input.charAt(start))) {
            start++;
        }
        while (end >= 0 && "\r\n \t".contains("" + input.charAt(end))) {
            end--;
        }

        if (start <= end)
            return input.substring(start, end + 1);
        else return "";
    }

}
