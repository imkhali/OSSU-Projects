package Model;

public abstract class HackStatement {
    private final int lineNumber;
    private final String line;

    public HackStatement(int lineNumber, String line) {
        this.lineNumber = lineNumber;
        this.line = line;
    }
    // convert Hack Assembly statement to its binary representation
    public abstract String getHackRepresentation();

    // EFFECT: convert the given integer val to binary with nBits number of bits
    protected static String convertDecimalToBinary(int val) {
        return String.format("%16s", (Integer.toBinaryString(val))).replace(" ", "0");
    }
}
