
module InstructionDecoder(
    input [15:0] instruction,
    output reg [2:0] opcode,
    output reg [1:0] op,
    output reg [2:0] Rn,
    output reg [2:0] Rd,
    output reg [1:0] sh,
    output reg [2:0] Rm,
    output reg [7:0] imm8
);
    
    assign opcode = instruction[15:13];
    assign op = instruction[12:11];
    assign Rn = instruction[10:8];
    assign Rd = instruction[7:5];
    assign sh = instruction[4:3];
    assign Rm = instruction[2:0];
    assign imm8 = instruction[7:0];

endmodule
