import java.io.*;

/**
 * Created by binder on 07.05.14.
 */
public class WikiBuilder {
    static String stylesheetsFN;
    static String nl = "\r\n";

    public static void main(String[] args) {
        String testFN = args[0];
        // folder which contains /t/xml
        stylesheetsFN = args[1];
        String outFN = args[2];
        System.out.println("write output to " + outFN);
        boolean testAlreadyRead = false;
        try {
            BufferedReader in = new BufferedReader(new FileReader(testFN));
            BufferedWriter out = null;
            String line = null;
            while ((line = in.readLine()) != null) {
                if (line.startsWith("#---")) {
                    out = readFileBreak(line, outFN);
                    testAlreadyRead = false;
                } else if (line.startsWith("##")) {
                    readCaption(out, line);
                    testAlreadyRead = false;
                } else if (line.startsWith("#")) {
                    if(testAlreadyRead){
                        out.write("-"+nl);
                        testAlreadyRead = false;
                    }
                    readComment(out, line);
                } else if (line.startsWith("like")) {
                    if(testAlreadyRead){
                        out.write("-"+nl);
                    }
                    readTest(in, out, line);
                    testAlreadyRead = true;
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
        String line = null;
        while (!tmp.contains(");") && (line = in.readLine()) != null) {
            tmp += nl + line;
        }

        out.write("input:" + nl);
        out.write("```xml" + nl);
        String input = getXML(stylesheetsFN + File.separator + getFileName(tmp));
        out.write(cleanNewLines(input) + nl);
        out.flush();
        out.write("```" + nl);
        out.write("output:" + nl);
        out.write("```xml" + nl);
        out.write(cleanNewLines(clearHTML(getHTML(tmp))) + nl);
        out.flush();
        out.write("```" + nl);
        out.flush();
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
        String line = null;
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
