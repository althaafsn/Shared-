`define VSEL_C 2'b00
`define VSEL_PC 2'b01
`define VSEL_IMM 2'b10
`define VSEL_MDATA 2'b11


module datapath (
    // clock
    clk,
    // register fetch  
    readnum, vsel, loada, loadb,
    // ALU
    shift, asel, bsel, ALUop, loadc, loads,
    // set register
    writenum, write, mdata, sximm8, pc, c,
    // output
    Z_out, datapath_out );

    input clk, loada, loadb, loadc, loads, write, asel, bsel;
    input [1:0] ALUop, shift, vsel; 
    input [2:0] readnum, writenum;
    input [15:0] mdata, sximm8, pc, c;
    input [4:0] imm5;
    output reg [2:0] status_out;
    output reg [15:0] datapath_out;

    wire sximm5 = {11{imm5[4]}, imm5}
    reg [15:0] data_in_reg, data_out_reg, A_FF, B_FF, s_out, A_in_ALU, B_in_ALU, out_ALU;
    reg [2:0] status; 

    shifter FileShifter(B_FF, shift, s_out);
    regfile REGFILE(data_in_reg, writenum, write, readnum, clk, data_out_reg);
    ALU ALUModule(A_in_ALU, B_in_ALU, ALUop, out_ALU, status);
    
    vDFF #(16) A_loader(clk & loada, data_out_reg, A_FF);
    vDFF #(16) B_loader(clk & loadb, data_out_reg, B_FF);
    vDFF #(16) C_loader(clk & loadc, out_ALU, datapath_out);
    vDFF #(3) status_loader(clk & loads, status, status_out);
    
    //Datapath in

    always_comb VSEL_MUX begin
        case(vsel):
            `VSEL_C: data_in_reg = c;
            `VSEL_PC: data_in_reg = pc;
            `VSEL_IMM: data_in_reg = sximm8;
            `VSEL_MDATA: data_in_reg = mdata;
        endcase
    end


    // always_comb begin
    //   if (vsel == 2'b01) begin
    //     data_in_reg <= datapath_in;
    //   end else begin
    //     data_in_reg <= datapath_out;
    //   end

    //   if (asel == 1'b1) begin
    //     A_in_ALU <= 16'b0;
    //   end else begin
    //     A_in_ALU <= A_FF;
    //   end

    //   if (bsel == 1'b1) begin
    //     B_in_ALU <= sximm5;
    //   end else begin
    //     B_in_ALU <= s_out;
    //   end
    // end

endmodule