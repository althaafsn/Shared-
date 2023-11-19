
`define SEL_D 3'b100
`define SEL_N 3'b010
`define SEL_M 3'b001

`define VSEL_C 2'b00
`define VSEL_PC 2'b01
`define VSEL_IMM 2'b10
`define VSEL_MDATA 2'b11

module cpu(clk,reset,s,load,in,out,N,V,Z,w);
    input clk, reset, s, load;
    input [15:0] in;
    output [15:0] out;
    output N, V, Z, w;

    // Construct instruction register, set it to load a new instruction when load is high
    reg [15:0] next_instruction;
    vDFF #(16) InstructionReg (clk & load, in, next_instruction);

    // DECODER, determines parmaters
    InstructionDecoder Dec (next_instruction, opcode, op, Rn, Rd, sh, Rm, imm8);
    
    // From decoder
    reg [2:0] opcode;  
    reg [1:0] op;
    reg [2:0] Rn;       // 1st operand
    reg [2:0] Rd;       // destination reg
    reg [1:0] sh;       // shift value
    reg [2:0] Rm;       // 2nd operand
    reg [7:0] imm8;     // ALT: 8 bit immediate

    // passOpCode and op to FSM

    // signals from FSM
    reg loads, loadb, loadc, loada, write;
    reg [2:0] nsel;
    reg [1:0] vsel;
    
    StateController FSM(
                        // external signals
                        .clk(clk),
                        .rst(reset),
                        .s(s),

                        // FSM inputs
                        .opcode(opcode),
                        .op(op),

                        // Output Signals
                        .loads(loads),
                        .loadc(loadc),
                        .loadb(loadb),
                        .loada(loada),
                        .write(write),
                        .nsel(nsel), // selects reg
                        .vsel(vsel) // select input
                        .w(w)       // to signal the state
                                                            );

    
    // MUX Rn, Rd, and Rm together, based on select
    // Sign extend imm8

    
    // ====== REGISTER SELECT

    reg [2:0] currentReg;

    always_comb begin
        case (nsel)
            `SEL_D: currentReg = Rd;
            `SEL_N: currentReg = Rn;
            `SEL_M: currentReg = Rm;
        endcase 
    end

    // ====== SIGN EXTENSION on IMM8

    reg [15:0] sximm8 = {{8{sximm8[7]}}, imm8};

    // For now set imm5 to 0, mdata to 0, and pc to 0
    reg [4:0] imm5 = 5'b00000;
    reg [15:0] pc = 0;
    reg [15:0] mdata = 0;
    
    // Now connect datapath to signals

    datapath dp (
                    // clock
                    clk,

                    // register fetch  
                    currentReg, vsel, loada, loadb,

                    // ALU
                    sh, asel, bsel, op, loadc, loads,

                    // immideate
                    imm5,

                    // set register
                    currentReg, write, mdata, sximm8, pc,

                    // output
                    status_out, out 
                                                            );

    // MAP STATUS_OUT to Z, V, and W
    assign {Z,V,W} = status_out;

    

    // ========================================= MODULES ==============================================================



    




//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


// SIGN-EXTEND imm8
    






endmodule
