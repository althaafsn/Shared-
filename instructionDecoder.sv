
module InstructionDecoder(
    input [15:0] instruction;
    output reg [2:0] opcode;
    output reg [1:0] op;
    output reg [2:0] Rn;
    output reg [2:0] Rd;
    output reg [1:0] sh;
    output reg [2:0] Rm;
    
);
    opcode = instruction[15:13];
    op = instruction[12:11];
    Rn = instruction[10:8];
    Rd = instruction[7:5];
    sh = instruction[4:3];
    Rm = instruction[2:0];


endmodule

// fetch instruction + decode -> fetch register -> ALU -> write to memory -> load -> fetch new 

// 