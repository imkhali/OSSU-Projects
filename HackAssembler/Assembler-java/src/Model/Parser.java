package Model;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Scanner;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class Parser {
    private final String srcPath;
    private final String destPath;
    /** Hack Assembly patterns and their matchers */
    private final Pattern aInst = Pattern.compile("@(?<address>[a-zA-Z0-9_.$]+)(?:\\s*//.*)?$");
    private final Pattern cInst = Pattern.compile("^(?<dest>[AMD]{0,3})=?(?<comp>(([-!]?[01ADM])|([ADM][-+&|][1ADM])));?(?<jump>(JGT|JEQ|JGE|JLT|JNE|JLE|JMP)?)(?:\\s\\*//.*)?$");
    private final Pattern label = Pattern.compile("\\(\\s?(?<label>[a-zA-Z_][a-zA-Z0-9_.$]*)\\s?\\)");
    private Matcher aInstMatcher, cInstMatcher, labelMatcher;

    private final List<HackStatement> parsed;

    public Parser(String srcPath) {
        this.srcPath = srcPath;
        this.destPath = nameDestFromSrc(srcPath);
        this.parsed = new ArrayList<>();
    }

    public String getSrcPath() {
        return srcPath;
    }

    public String getDestPath() {
        return destPath;
    }

    public List<HackStatement> getParsed() {
        return parsed;
    }

    //MODIFIES: this
    // EFFECTS: parse srcFile and save parsed HackAssembly Statements in parsed
    //          ignores comments and empty lines
    public void parse() {
        String curLine;
        int lineNumber;
        // reading from asm file
        try {
            File srcFile = new File(srcPath);
            Scanner scanner = new Scanner(srcFile);
            lineNumber = 0;
            while(scanner.hasNextLine()) {
                lineNumber++;
                curLine = scanner.nextLine().strip();
                if ((curLine.length() > 0) && !curLine.startsWith("//"))
                    processLine(curLine, lineNumber);
            }
        } catch (FileNotFoundException e) {
            System.out.println("An error occurred.");
            e.printStackTrace();
        }
        // writing to hack file
        try {
            FileWriter destFile = new FileWriter(destPath);
            for (HackStatement statement: parsed)
                destFile.write(statement.getHackRepresentation() + System.getProperty("line.separator"));
            destFile.close();
            System.out.println("Successfully wrote to the file. " + destPath);
        } catch (IOException e) {
            System.out.println("An error occurred.");
            e.printStackTrace();
        }
    }

    //EFFECTS: return size of list of parsed statements
    public int parsedSize() {
        return parsed.size();
    }

    // EFFECTS: return destFile path given srcFile path (same but with .hack extension)
    private String nameDestFromSrc(String srcFile) {
        return srcFile.substring(0, srcFile.lastIndexOf('.')) + ".hack";
    }

    //REQUIRES: length of line > 0 and trimmed of leading and trailing whitespace
    //MODIFIES: this
    // EFFECTS: parse scrFile line and save its parsed statement (if any) into parsed
    private void processLine(String line, int lineNumber) {
        HackStatement statement = null;
        aInstMatcher = aInst.matcher(line);
        if (aInstMatcher.matches()) {
            parsed.add(new AInstruction(lineNumber, line, aInstMatcher.group("address")));
            return;
        }
        cInstMatcher = cInst.matcher(line);
        if (cInstMatcher.matches()) {
            parsed.add(new CInstruction(lineNumber, line, cInstMatcher.group("dest"),
                    cInstMatcher.group("comp"), cInstMatcher.group("jump")));
            return;
        }
        // TODO: add case to parse labels
        throw new RuntimeException(
                "Line no " + lineNumber + ": \"" + line + "\" not matched to a HackAssembly statement"
        );
    }
}
