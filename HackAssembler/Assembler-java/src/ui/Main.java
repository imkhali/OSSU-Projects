package ui;

import Model.HackStatement;
import Model.Parser;

// TODO: done with version one (without labels)
public class Main {
    public static void main(String[] args) {
        Parser parser = new Parser("..\\max\\MaxL.asm");
        parser.parse();
        for (HackStatement statement: parser.getParsed()) {
            System.out.println(statement.toString());
        }
    }
}
