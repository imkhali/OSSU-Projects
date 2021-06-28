"""
HackAssembler a program that translates Hack assembly programs into executable Hack Binary code
Usage: python HackAssembler Xxx.asm
Return: Xxx.hack
Assumption: Xxx.asm is error-free
"""

import re
import os
import sys


class HackStatment:
    def __str__(self):
        return '{}({})'.format(self.__class__.__name__, ', '.join('{}={}'.format(attr, repr(value)) for attr, value in self.__dict__.items()))

    def __repr__(self):
        return '{}({})'.format(self.__class__.__name__, ', '.join('{}'.format(repr(value)) for value in self.__dict__.values()))

    def __init__(self, line):
        self.line = line

    def decimal_to_binary(self, val, nbits):
        """convert val to its 16 bit repr. max val accepted is 32765

        Args:
            val (int): value to convert

        Returns:
            [str]: binary repr.
        """
        val = int(val)
        if val >= 0:
            return '{:0{n}b}'.format(val, n=nbits)


class AInstruction(HackStatment):
    BUILTINS = dict(R0='0', R1='1', R2='2', R3='3', R4='4', R5='5', R6='6', R7='7',
                    R8='8', R9='9', R10='10', R11='11', R12='12', R13='13', R14='14', R15='15',
                    SCREEN='16384', KBD='24576',
                    SP='0', LCL='1', ARG='2', THIS='3', THAT='4')

    def __init__(self, line, address=''):
        super().__init__(line)
        self.address = self.BUILTINS.get(address, address)

    def get_binary_repr(self):
        # a instruction leftmost bit is specified as 0
        return '0' + self.decimal_to_binary(self.address, 15)


class CInstruction(HackStatment):

    BB_COMP = {'0': '0101010', '1': '0111111', '-1': '0111010', 'D': '0001100',
               'A': '0110000', '!D': '0001101', '!A': '0110001', '-D': '0001111',
               '-A': '0110011', 'D+1': '0011111', 'A+1': '0110111', 'D-1': '0001110',
               'A-1': '0110010', 'D+A': '0000010', 'D-A': '0010011', 'A-D': '0000111',
               'D&A': '0000000', 'D|A': '0010101', 'M': '1110000', '!M': '1110001',
               '-M': '1110011', 'M+1': '1110111', 'M-1': '1110010', 'D+M': '1000010',
               'D-M': '1010011', 'M-D': '1000111', 'D&M': '1000000', 'D|M': '1010101'}

    BB_DEST = {'': '000', 'M': '001', 'D': '010', 'MD': '011',
        'A': '100', 'AM': '101', 'AD': '110', 'AMD': '111', }

    BB_JUMP = {'': '000', 'JGT': '001', 'JEQ': '010', 'JGE': '011',
        'JLT': '100', 'JNE': '101', 'JLE': '110', 'JMP': '111', }

    def __init__(self, line, dest='', comp='', jump=''):
        super().__init__(line)
        self.dest = dest
        self.comp = comp
        self.jump = jump

    def get_binary_repr(self):
        result = '111' + self.BB_COMP[self.comp] + \
            self.BB_DEST[self.dest] + self.BB_JUMP[self.jump]
        return result


class Label(HackStatment):
    def __init__(self, line, name, reference):
        super().__init__(line)
        self.name = name
        self.reference = reference


class Parser:
    OFFSETVARS = 16

    instructions = dict(
        # COMMENT = r'''^//.*$''',
        A_INSTRUCTION=re.compile(
            r'''^@(?P<address>[a-zA-Z0-9_.$]+)(?:\s*//.*)?$'''),  # the main diff with java so far is no raw, so need extra backslah and no (?P<>...) instead (?<>...)
        C_INSTRUCTION=re.compile(
            r'''^(?P<dest>[AMD]{0,3})=?(?P<comp>(([-!]?[01ADM])|([ADM][-+&|][1ADM])));?(?P<jump>(JGT|JEQ|JGE|JLT|JNE|JLE|JMP)?)(?:\s*//.*)?$'''),
        LABEL=re.compile(
            r'''\(\s?(?P<label>[a-zA-Z_]{1}[a-zA-Z0-9_.$]*)\s?\)'''),
    )

    def __init__(self, source_file, output_file=None):
        self.source_file = source_file
        self.output_file = output_file
        self.data = []
        self.labels = []
        self.varCount = 0

    @property
    def source_file(self):
        return self._source_file

    @source_file.setter
    def source_file(self, source_file):
        if not (os.path.exists(source_file) and os.path.isfile(source_file) and source_file.endswith('.asm')):
            raise FileNotFoundError(
                "{} not found or not assembly source file".format(source_file))
        self._source_file = source_file

    @property
    def output_file(self):
        return self._output_file

    @output_file.setter
    def output_file(self, output_file):
        self._output_file = output_file or os.path.splitext(self._source_file)[
                                                            0] + '.hack'

    def parse(self):
        with open(self._source_file) as rf, open(self._output_file, 'w') as wf:
            self._construct_statments(rf)
            for statement in self.data:
                if isinstance(statement, AInstruction) and not statement.address.isdigit():
                    statement = self._fix_addresses(statement)
                wf.write(statement.get_binary_repr() + '\n')

    def _construct_statments(self, buffer):
        line_num = 0
        count_instructions = 0
        for line in buffer:
            line_num += 1
            line = line.strip()
            # discard empty or commented lines
            if line and not line.startswith('//'):
                for name, pattern in self.instructions.items():
                    match = pattern.match(line)
                    if match:
                        if name == 'A_INSTRUCTION':                                                    # case A instruction
                            count_instructions += 1
                            self.data.append(AInstruction(
                                line_num, match.group('address')))
                        elif name == 'C_INSTRUCTION':                                                  # case C Instruction
                            count_instructions += 1
                            self.data.append(CInstruction(line_num, match.group(
                                'dest'), match.group('comp'), match.group('jump')))
                        elif name == 'LABEL':
                            # case Label, refers to next A or C Instruction, not yielded as it is not an instruction
                            self.labels.append(
                                Label(line_num, match.group('label'), str(count_instructions)))
                        else:
                            raise RuntimeError('Unexpected Error')
                        break

    def _fix_addresses(self, aStatement):
        """
        check aStatment address across labels and get label next instruction reference as address of the
        aStatment, if not aStatment address is variable and got assigned next position in variables addresses
        """
        for label in self.labels:                     # case one (address in labels)
            if aStatement.address == label.name:
                aStatement.address = label.reference
                return aStatement
        # case two (address is a new var)
        aStatement.address = str(self.varCount + self.OFFSETVARS)
        return aStatement


if __name__ == '__main__':
    if len(sys.argv) != 2: 
        print("Usage: HackAssembler <path to Hack assembly file>")
        sys.exit(-1)
    asmFile = sys.argv[1]
    p = Parser(asmFile)
    p.parse()
                       
