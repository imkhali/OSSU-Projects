package Model;

import java.util.Map;
import java.util.stream.Collectors;
import java.util.stream.Stream;

public class AInstruction extends HackStatement {

    private static Map<String, String> bAddresses;
    static {
        bAddresses = Stream.of(new String[][] {
                { "R0", "0" },
                { "R1", "1" },
                { "R2", "2" },
                { "R3", "3" },
                { "R4", "4" },
                { "R5", "5" },
                { "R6", "6" },
                { "R7", "7" },
                { "R8", "8" },
                { "R9", "9" },
                { "R10", "10" },
                { "R11", "11" },
                { "R12", "12" },
                { "R13", "13" },
                { "R14", "14" },
                { "R15", "15" },
                { "SCREEN", "16384" },
                { "KBD", "24576" },
                { "SP", "0" },
                { "LCL", "1" },
                { "ARG", "2" },
                { "THIS", "3" },
                { "THAT", "4" }
        }).collect(Collectors.toMap(data -> data[0], data -> data[1]));
    }

    private String address;

    public AInstruction(int lineNumber, String line, String address) {
        super(lineNumber, line);
        this.address = address;
    }

    @Override
    public String getHackRepresentation() {
        String binAddress = bAddresses.containsKey(address) ? bAddresses.get(address): address;
        try {
            return convertDecimalToBinary(Integer.parseInt(binAddress));
        } catch (NumberFormatException e) {
            e.printStackTrace();
        }
        return "";
    }

    @Override
    public String toString() {
        return "AInstruction{" +
                "address='" + address + '\'' +
                '}';
    }
}
