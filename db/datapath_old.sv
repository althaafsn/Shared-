module datapath_tb_old();
  reg clk, sim_vsel, sim_loada, sim_loadb, sim_loadc, sim_loads, sim_write, sim_asel, sim_bsel;
  reg [1:0] sim_ALUop, sim_shift; 
  reg [2:0] sim_readnum, sim_writenum;
  reg err;

  // output
  reg [15:0] sim_datapath_in, sim_datapath_out;
  reg [15:0] allRegs [7:0] = {DUT.R7, DUT.R6, DUT.R5, DUT.R4, DUT.R3, DUT.R2, DUT.R1, DUT.R0};  
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
    sim_writenum = Dest;
    sim_datapath_in = WriteVal;
    vsel = 1'b1;

    #4; // after rising edge

    assert (allRegs[Dest] == WriteVal) $display ("Overwrite to R%d sucessful!", Dest);
    else begin 
      $display ("Overwrite to R%d failed, got %d instead of %d", Dest, allRegs[Dest], WriteVal)
    end
  endtask

  // task MOV_Reg;
  //   input [2:0] Dest;
  //   input [2:0] Source;

  //   sim_write = 1'b0;
  //   sim_readnum = 1'b1;


  // endtask
  
  task ADD;
    input [2:0] Dest;
    input [2:0] Ain;
    input [2:0] Bin;
    input [1:0] shift;
    input [15:0] expected;
    
    sim_write = 1'b0;
    sim_loada = 0;
    sim_loadb = 0;
    sim_loadc = 0;
    sim_loads = 0;
    sim_ALUop = 2'b00;
    sim_asel = 0;
    sim_bsel = 0;
    sim_vsel = 0;

    sim_writenum = Dest;

    // Read and load from Ain
    sim_readnum = Ain;
    loada = 1'b1;

    // load A

    #4;
    loada = 0;

    // Read from Bin
    sim_readnum = Bin;
    loadb = 1'b1;

    #4
    loadb = 1'b0;

    // Caclulates A + B, load to C and S
    loadc = 1'b1;
    loads = 1'b1;
    #4;
    
    // Now write to Dest
    assert (datapath_out == expected) $display ("ADD sucesssful");
    else begin 
      $display("ADD unsuccessful, got %d but expected %d");
      err = 1'b1;
    end

    // Check Z value
    if (datapath_out == 0) begin
      assert (Z_out == 1'b1) $display ("ADD sucesssful");
      else begin 
        $display("Status incorrect, got %d but expected %d");
        err = 1'b1;
      end
    end else begin
      assert (Z_out == 1'b0) $display ("ADD sucesssful");
      else begin 
        $display("Status incorrect, got %d but expected %d");
        err = 1'b1;
      end
    end 
    
    MOV(Dest, datapath_out);

  endtask

  task ADD_I(Dest, Ain, IMM, shift, expected);
  
  endtask

  task SUB(Dest, Ain, Bin, shift, expected);
    
  endtask

  task SUB_I(Dest, Ain, Bin, shift, expected);
    
  endtask

  task LS(Dest, Reg, shift, expected);
    
  endtask

  task MVN(Dest, Reg, shift, expected);
    
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
  sim_write = 1'b1;
  sim_vsel = 1'b1;

  //Writing 50 to R0
  sim_writenum = 0;
  sim_datapath_in = 50;
  #10;

  assert (DUT.REGFILE.R0 == sim_datapath_in) $display("Passed overwriting R0 with %d", sim_datapath_in);
  else begin
    $display ("FAILED Overwriting R0, expected %d but got %d", sim_datapath_in, DUT.REGFILE.R0);
    err = 1'b1;
  end 
  

  //Test MOV R1 21
  sim_write = 1'b1;

  //Writing 21 to R1
  sim_writenum = 1;
  sim_datapath_in = 21;
  #10;

  assert (DUT.REGFILE.R1 == sim_datapath_in) $display("Passed overwriting R0 with %d", sim_datapath_in);
  else begin
      $display ("FAILED Overwriting R1, expected %d but got %d", sim_datapath_in, DUT.REGFILE.R1);
      err = 1'b1;
  end

  //TEST ADD R2 R0 R1
  sim_write = 1'b0;
  sim_asel = 0;
  sim_bsel = 0;
  sim_ALUop = 2'b00;

  //Load R0 to A
  sim_writenum = 1;
  sim_readnum = 0;
  sim_datapath_in = 21;
  sim_loada = 1;
  sim_loadb = 0;
  #10;

  //Load R1 to B
  sim_writenum = 1;
  sim_readnum = 1;
  sim_datapath_in = 21;
  sim_loada = 0;
  sim_loadb = 1;
  #10

  //Loadb to shifter
  sim_shift = 2'b00;
  #10

  //Add R0 and R1  
  sim_ALUop = 2'b00;
  #10;

  //Test datapath_out and Z_out after addition
  sim_loadc = 1'b1;
  sim_loads = 1'b1;
  #10;
  
  assert (sim_datapath_out == 71) $display("Passed adding R0 with R1");
  else begin
    $display ("FAILED adding R0 and R1, expected 71 but got %d", sim_datapath_out);
    err = 1'b1;
  end
  assert (sim_Z_out == 0) $display("Passed adding R0 with R1");
  else begin
    $display ("FAILED adding R0 and R1, expected Z = 0 but got %d", sim_Z_out);
    err = 1'b1;
  end
  

  assert (err == 0) $display ("Passed all tests");
  else $display ("FAILED");
  $stop;
end
  

endmodule