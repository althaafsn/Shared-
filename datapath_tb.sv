`define NO_SHIFT 2'b00
`define L_1 2'b01
`define R_1 2'b10
`define R_X 2'b11

`define ADD 2'b00
`define SUB 2'b01
`define AND 2'b10
`define MVN 2'b11

`define r0 0
`define r1 1
`define r2 2
`define r3 3
`define r4 4
`define r5 5
`define r6 6
`define r7 7

module datapath_tb();
  reg clk, sim_vsel, sim_loada, sim_loadb, sim_loadc, sim_loads, sim_write, sim_asel, sim_bsel;
  reg [1:0] sim_ALUop, sim_shift; 
  reg [2:0] sim_readnum, sim_writenum;
  reg err;

  // output
  reg signed [15:0] sim_datapath_in, sim_datapath_out;
  wire signed   [15:0] allRegs [7:0];
  
assign allRegs = {DUT.REGFILE.R7,
                DUT.REGFILE.R6, 
                DUT.REGFILE.R5, 
                DUT.REGFILE.R4, 
                DUT.REGFILE.R3, 
                DUT.REGFILE.R2, 
                DUT.REGFILE.R1, 
                DUT.REGFILE.R0};  
  reg sim_Z_out;

  // wire [15:0] allRegs [7:0];  

  // task assert_Val (expectedOut, );

  // endtask

  // MOV for immediate values
  task MOV;
    input [2:0] Dest;
    input [15:0] WriteVal;

    // Sets write mode to 1
    sim_write = 1'b1;
    sim_vsel = 1'b1;
    sim_datapath_in = WriteVal;
    sim_writenum = Dest;

    #4; // after rising edge

    assert (allRegs[Dest] == WriteVal) $display ("Overwrite to R%d sucessful!", Dest);
    else begin 
      $display ("Overwrite to R%d failed, got %d instead of %d", Dest, allRegs[Dest], WriteVal);
      err = 1'b1;
    end

    #4;
  endtask

  // task MOV_Reg;
  //   input [2:0] Dest;
  //   input [2:0] Source;

  //   sim_write = 1'b0;
  //   sim_readnum = 1'b1;


  // endtask
  
 
   // ALU operations which operates on 2 regs and pust them in dest
  task AritOP;
    input [1:0] OP;
    input [2:0] Dest;
    input [2:0] Ain;
    input [2:0] Bin;
    input [1:0] shift;
    input signed [15:0] expectedVal;
    input expectedZ;
    
    // Initialization
    sim_ALUop = OP;
    sim_writenum = Dest;
    sim_write = 1'b0;
    sim_loada = 0;
    sim_loadb = 0;
    sim_loadc = 0;
    sim_loads = 0;
    sim_asel = 0;
    sim_bsel = 0;
    sim_vsel = 0;
    sim_shift = shift;

    // Read and load from Ain
    sim_readnum = Ain;
    sim_loada = 1'b1;

    // load A
    #4;
    sim_loada = 0;

    // Read from Bin
    sim_readnum = Bin;
    sim_loadb = 1'b1;

    #4
    sim_loadb = 1'b0;

    // Caclulates A + B, load to C and S
    sim_loadc = 1'b1;
    sim_loads = 1'b1;
    #4;

    sim_loadc = 1'b0;
    sim_loads = 1'b0;
    
    // Now write to Dest
    assert (sim_datapath_out == expectedVal) $display ("ADD sucesssful");
    else begin 
      $display("ADD unsuccessful, got %d but expected %d", sim_datapath_out, expectedVal);
      err = 1'b1;
    end

    // Check Z value
    if (sim_datapath_out == 0) begin
      assert (sim_Z_out == 1'b1) $display ("ADD sucesssful");
      else begin 
        $display("Status incorrect, got %b but expected %b", sim_Z_out, expectedZ);
        err = 1'b1;
      end
    end else begin
      assert (sim_Z_out == 1'b0) $display ("ADD sucesssful");
      else begin 
        $display("Status incorrect, got %b but expected %b", sim_Z_out, expectedZ);
        err = 1'b1;
      end
    end 
    
    MOV(Dest, sim_datapath_out);
    #4;

  endtask

  // ALU operations with immediate values.
  task OP_I;
    input [1:0] OP;
    input [2:0] Dest;
    input [2:0] Ain;
    input [4:0] IMM;
    input [1:0] shift;
    input signed [15:0] expectedVal;
    input expectedZ;
    
    sim_write = 1'b0;
    sim_loada = 0;
    sim_loadb = 0;
    sim_loadc = 0;
    sim_loads = 0;
    sim_ALUop = OP;
    
    // Fetch a, but do not fetch b
    sim_asel = 0;
    sim_bsel = 1;

    sim_vsel = 0;
    sim_shift = shift;

    sim_writenum = Dest;

    // Read and load from Ain
    sim_readnum = Ain;
    sim_loada = 1'b1;

    // load A
    #4;

    // Set value of B
    sim_loada = 0;
    sim_datapath_in = {{11{1'b0}}, IMM};
    #4

    // Caclulates A + B, load to C and S
    sim_loadc = 1'b1;
    sim_loads = 1'b1;
    #4;

    sim_loadc = 1'b0;
    sim_loads = 1'b0;
    
    // Now write to Dest
    assert (sim_datapath_out == expectedVal) $display ("Operation %b sucesssful", OP);
    else begin 
      $display("Operation %b unsuccessful, got %d but expected %d", OP, sim_datapath_out, expectedVal);
      err = 1'b1;
    end

    // Check Z value
    if (sim_datapath_out == 0) begin
      assert (sim_Z_out == 1'b1) $display ("ADD sucesssful");
      else begin 
        $display("Status incorrect, got %b but expected %b", sim_Z_out, expectedZ);
        err = 1'b1;
      end
    end else begin
      assert (sim_Z_out == 1'b0) $display ("ADD sucesssful");
      else begin 
        $display("Status incorrect, got %b but expected %b", sim_Z_out, expectedZ);
        err = 1'b1;
      end
    end 
    
    MOV(Dest, sim_datapath_out);
    #4;
  
  endtask

  // Shifting logic
  task LS;
    input [1:0] shift;
    input [2:0] Dest;
    input [2:0] Reg;
    input signed [15:0] expectedVal;
    input expectedZ;
    
    // Initialization
    sim_ALUop = `ADD;
    sim_writenum = Dest;
    sim_write = 1'b0;
    sim_loada = 0;
    sim_loadb = 0;
    sim_loadc = 0;
    sim_loads = 0;
    
    // Set a to 0 (one operand)
    sim_asel = 1;
    sim_bsel = 0;
    sim_vsel = 0;
    sim_shift = shift;

    // Read from Reg 
    sim_readnum = Reg;
    sim_loadb = 1'b1;

    #4
    sim_loadb = 1'b0;

    // Caclulates A + B, load to C and S
    sim_loadc = 1'b1;
    sim_loads = 1'b1;
    #4;

    sim_loadc = 1'b0;
    sim_loads = 1'b0;
    
    // Now write to Dest
    assert (sim_datapath_out == expectedVal) $display ("Shift is corrrect");
    else begin 
      $display("Shift unsuccessful, got %b but expected %b", sim_datapath_out, expectedVal);
      err = 1'b1;
    end

    // Check Z value
    if (sim_datapath_out == 0) begin
      assert (sim_Z_out == 1'b1) $display ("ADD sucesssful");
      else begin 
        $display("Status incorrect, got %b but expected %b", sim_Z_out, expectedZ);
        err = 1'b1;
      end
    end else begin
      assert (sim_Z_out == 1'b0) $display ("ADD sucesssful");
      else begin 
        $display("Status incorrect, got %b but expected %b", sim_Z_out, expectedZ);
        err = 1'b1;
      end
    end 
    
    MOV(Dest, sim_datapath_out);
    #4;

  endtask

  // Move and negate register value
  task MVN;
    input [2:0] Dest;
    input [2:0] Reg;
    input [1:0] shift;
    input [15:0] expectedVal;
    input expectedZ;
    
    // Initialization
    sim_ALUop = `MVN;
    sim_writenum = Dest;
    sim_write = 1'b0;
    sim_loada = 0;
    sim_loadb = 0;
    sim_loadc = 0;
    sim_loads = 0;
    sim_asel = 1; // set a to 0 (1 operannd)
    sim_bsel = 0;
    sim_vsel = 0;
    sim_shift = shift;

    // Read from Reg
    sim_readnum = Reg;
    sim_loadb = 1'b1;

    #4
    sim_loadb = 1'b0;

    // Caclulates ~B, load to C and S
    sim_loadc = 1'b1;
    sim_loads = 1'b1;
    #4;

    sim_loadc = 1'b0;
    sim_loads = 1'b0;
    
    // Now write to Dest
    assert (sim_datapath_out == expectedVal) $display ("MVN output OK");
    else begin 
      $display("MVN unsuccessful, got %b but expected %b", sim_datapath_out, expectedVal);
      err = 1'b1;
    end

    // Check Z value
    if (sim_datapath_out == 0) begin
      assert (sim_Z_out == 1'b1) $display ("MVN sucesssful");
      else begin 
        $display("Status incorrect, got %b but expected %b", sim_Z_out, expectedZ);
        err = 1'b1;
      end
    end else begin
      assert (sim_Z_out == 1'b0) $display ("MVN sucesssful");
      else begin 
        $display("Status incorrect, got %b but expected %b", sim_Z_out, expectedZ);
        err = 1'b1;
      end
    end 
    
    MOV(Dest, sim_datapath_out);
    #4;
    
  endtask

  datapath DUT (.clk         (clk),

              // register operand fetch stage
              .readnum     (sim_readnum),
              .vsel        (sim_vsel),
              .loada       (sim_loada),
              .loadb       (sim_loadb),

              // computation stage (sometimes called "execute")
              .shift       (sim_shift),
              .asel        (sim_asel),
              .bsel        (sim_bsel),
              .ALUop       (sim_ALUop),
              .loadc       (sim_loadc),
              .loads       (sim_loads),

              // set when "writing back" to register file
              .writenum    (sim_writenum),
              .write       (sim_write),  
              .datapath_in (sim_datapath_in),

              // outputs
              .Z_out       (sim_Z_out),
              .datapath_out(sim_datapath_out));

  initial forever begin
    clk = 1'b0; #2;
    clk = 1'b1; #2;
  end

  //Version one of instructions execution
  // MOV R0 50
  // MOV R1 21
  // ADD R2 R0 R1 // output should be 71                                                           
  // SUB R3 R0 R1 // output should be 29
  // AND R4 R0 R1 // 0000 0000 0000 0000 & 0000 0000 0000 0000 
  // LSR R4 R2 1
  // ADD R5 R2 R3 LSL 1
  // SUB R6 R2 R4 LSR 1
  initial begin

  //Test MOV R0 50
  err = 0;
  
  // The following lines describe the assembly code line by line

  // MOV R0 50
  // MOV R1 21
  // ADD R2 R0 R1 // output should be 71                                                           
  // SUB R3 R0 R1 // output should be 29
  // AND R4 R0 R1 // 0000 0000 0011 0010 & 0000 0000 0001 0101 = 0000 0000 0001 0000 
  // LSR R4 R2 1 // R4 = 35;
  // ADD R5 R2 R3 LSL 1 // R5 = R2 + 2R3 = 71 + 58 = 129 
  // SUB R6 R2 R4 LSR 1 = 71 - 34/2 = 54
  // SUB R6 R6 R6 LSL 1  = -54
  // SUB R6 R6 R6 = 0 (Z = 1)
  // MOV R7 6
  // MVN R7 R7;
  // ADD R7 R7 #1;
  // ADD R7 R7 #25 // R7 =  19
 

  MOV(`r0, 50);
  MOV (`r1, 21);
  AritOP(`ADD, `r2, `r0, `r1, `NO_SHIFT, 71, 0);
  AritOP(`SUB, `r3, `r0, `r1, `NO_SHIFT, 29, 0);
  AritOP(`AND, `r4, `r0, `r1, `NO_SHIFT, 16'b0000_00000_0001_0000, 0);
  LS(`R_1, `r4, `r2, 35, 0);
  AritOP(`ADD, `r5, `r2, `r3, `L_1, 129, 0);
  AritOP(`SUB, `r6, `r2, `r4, `R_1, 54, 0);
  AritOP(`SUB, `r6, `r6, `r6, `L_1, -54, 0);
  AritOP(`SUB, `r6, `r6, `r6, `NO_SHIFT, 0, 1);
  MOV(`r7, 6);
  MVN(`r7, `r7, `NO_SHIFT, 16'b1111_1111_1111_1001, 0);
  OP_I(`ADD, `r7, `r7, 1, `NO_SHIFT, -6, 0);
  OP_I(`ADD, `r7, `r7, 25, `NO_SHIFT, 19, 0);

  assert (err == 0) $display ("Passed all tests");
  else $display ("FAILED");
  #220;
  $stop;
end  

endmodule