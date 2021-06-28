package test;

import Model.Parser;
import org.junit.Test;

import static org.junit.Assert.assertEquals;

public class ParserTest {
    private Parser parser;

    @Test
    public void testGetters() {
        String fileName = "C:\\Users\\khalil\\OneDrive - Deakin University\\PhD Project\\Programming\\CSDegree\\019_020_NAND_TETRIS\\projects\\06\\max\\MaxL.asm";
        parser = new Parser(fileName);
        assertEquals(parser.getSrcPath(), fileName);
        assertEquals(parser.getDestPath(), "C:\\Users\\khalil\\OneDrive - Deakin University\\PhD Project\\Programming\\CSDegree\\019_020_NAND_TETRIS\\projects\\06\\max\\MaxL.hack");
    }
}
