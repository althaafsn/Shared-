module datapath (
    // clock
    clk,
    // register fetch  
    readnum, vsel, loada, loadb,
    // ALU
    shift, asel, bsel, ALUop, loadc, loads,
    // set register
    writenum, write, datapath_in,
    // output
    Z_out, datapath_out );

    input clk, vsel, loada, loadb, loadc, loads, write, asel, bsel;
    input [1:0] ALUop, shift; 
    input [2:0] readnum, writenum;
    input [15:0] datapath_in; 
    output reg Z_out;
    output reg [15:0] datapath_out;

    reg [15:0] data_in_reg, data_out_reg, A_FF, B_FF, s_out, A_in_ALU, B_in_ALU, out_ALU;
    reg Z;
    
    shifter FileShifter(B_FF, shift, s_out);
    regfile REGFILE(data_in_reg, writenum, write, readnum, clk, data_out_reg);
    ALU ALUModule(A_in_ALU, B_in_ALU, ALUop, out_ALU, Z);
    
    // DFFs for each loader
    vDFF #(16) A_loader(clk & loada, data_out_reg, A_FF);
    vDFF #(16) B_loader(clk & loadb, data_out_reg, B_FF);
    vDFF #(16) C_loader(clk & loadc, out_ALU, datapath_out);
    vDFF #(1) status_loader(clk & loads, Z, Z_out);
    
    //Datapath in
    always_comb begin
      // vsel, checks if the register should accept data_write or result from calculations
      if (vsel == 1'b1) begin
        data_in_reg <= datapath_in;
      end else begin
        data_in_reg <= datapath_out;
      end

      // A sel
      if (asel == 1'b1) begin
        A_in_ALU <= 16'b0;
      end else begin
        A_in_ALU <= A_FF;
      end

      // B sel
      if (bsel == 1'b1) begin
        B_in_ALU <= {11'b0, datapath_in[4:0]};
      end else begin
        B_in_ALU <= s_out;
      end
    end

endmodule