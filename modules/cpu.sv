
`define SEL_D 3'b100
`define SEL_N 3'b010
`define SEL_M 3'b001

`define VSEL_C 2'b00
`define VSEL_PC 2'b01
`define VSEL_IMM 2'b10
`define VSEL_MDATA 2'b11

// MEMORY COMMAND
`define MNONE 2'b00     // Does nothing to the RAM
`define MREAD 2'b01     // Reads data from RAM
`define MWRITE 2'b10    // Write data to RAM

module cpu(clk,reset, mem_cmd, mem_addr, read_data, out, N,V,Z);
    input clk, reset;
    output reg [1:0] mem_cmd;
    output [8:0] mem_addr;
    input [15:0] read_data;
    output [15:0] out;
    output N, V, Z;

    parameter filename = "data.txt";

    // SIGNAL DECLARATION

    // From decoder
    reg [2:0] opcode;  
    reg [1:0] op;
    reg [2:0] Rn;       // 1st operand
    reg [2:0] Rd;       // destination reg
    reg [1:0] in_shift;       // shift value
    reg [2:0] Rm;       // 2nd operand
    wire [7:0] imm8;    // ALT: 8 bit immediate

    // Input and output signals for PC controller
    reg reset_pc, load_pc;
    reg [8:0] PC;

    // Instruction Register
    reg [15:0] next_instruction;
    reg [15:0] read_data;
    reg load_ir;

    // Memory
    reg addr_sel, load_addr;

    // signals from FSM
    reg loads, loadb, loadc, loada, write;
    reg [2:0] nsel, sh;
    reg [1:0] vsel, sel;

    // ====== SIGN EXTENSION on IMM8
    wire [15:0] sximm8 = {{8{imm8[7]}}, imm8};

    
    // MEMORY
    // NOW connect PC to the pc_con module, and m_data to read_data.
    reg [15:0] mdata = read_data;
    reg [15:0] pc = 0;
    reg [8:0] dataAddress; // CHANGE THIS


    // TO DATAPATH
    reg [2:0] currentReg;   // CURRENT REGISTER TO READ/WRITE
    wire asel, bsel;        // SELECT OUTPUT
    assign {bsel, asel} = sel;
    reg [4:0] imm5 = 5'b00000;
    wire [2:0] status_out;


    //////////////////////////////////// PREVIOUS VERSION /////////////////////////////////////////////////

    // DECODER, determines parameters
    InstructionDecoder Dec (next_instruction, opcode, op, Rn, Rd, in_shift, Rm, imm8);

    // Instantiation of PC controller
    pc_controller PC_CON(
        .clk(clk),
        .reset_pc(reset_pc),
        .load_pc(load_pc),
        .pc(PC)
    );

    // pass OpCode and op to FSM
    
    StateController FSM(
                        // external signals
                        .clk(clk),
                        .rst(reset),
                        // removed s

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
                        .vsel(vsel), // select input
                        .sel(sel),

                        // PC and Mem Control signals
                        .reset_pc(reset_pc),
                        .load_pc(load_pc),
                        .addr_sel(addr_sel),
                        .load_ir(load_ir),  // loads new instruction
                        .load_addr(load_addr), // loads new address to read/write
                        .mem_cmd(mem_cmd)
                        .in_shift (in_shift)
                        .sh (sh)
                                                            );

    
    // MUX Rn, Rd, and Rm together, based on select
    // Sign extend imm8
    
    // Now connect datapath to signals

    datapath DP (
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
    assign {Z,V,N} = status_out;

// ================================ COMBINATIONAL LOGIC ================================

    always_comb begin
        // ====== REGISTER SELECT
        case (nsel)
            `SEL_D: currentReg = Rd;
            `SEL_N: currentReg = Rn;
            `SEL_M: currentReg = Rm;
				default: currentReg = 3'bxxx;
        endcase 

    end

    // ====== ADDRESS SELECT
    assign mem_addr = addr_sel ? PC : dataAddress;


// ============================== REGISTERS ====================================

    always_ff @(posedge clk) begin
        ///////////////////// ADDED INSTRUCTION REGISTER ///////////////////////////////////
        
        // Construct instruction register, set it to load a new instruction when load_ir is high
        if (load_ir) begin
            next_instruction = read_data;
        end else begin
            next_instruction = next_instruction;
        end

        /////////////////// LOADING DATA_ADDRESS //////////////////////////////////////////
        if (load_addr == 1'b1) begin
            dataAddress = out[8:0];
        end else dataAddress = dataAddress;

    end

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

endmodule
