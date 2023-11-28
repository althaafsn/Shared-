// WARNING: This is NOT the autograder that will be used mark you.  
// Passing the checks in this file does NOT (in any way) guarantee you 
// will not lose marks when your code is run through the actual autograder.  
// You are responsible for designing your own test benches to verify you 
// match the specification given in the lab handout.

module lab7_check_tb;
  reg [3:0] KEY;
  reg [9:0] SW;
  wire [9:0] LEDR; 
  wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
  reg err;

  lab7_top DUT(KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5);

  initial forever begin
    KEY[0] = 0; #5;
    KEY[0] = 1; #5;
  end

  initial begin
    err = 0;
    KEY[1] = 1'b0; // reset asserted
    // check if program from Figure 6 in Lab 7 handout can be found loaded in memory
    if (DUT.MEM.mem[0] !== 16'b110_10_000_000_01000) begin err = 1; $display("FAILED: mem[0] wrong; please set data.txt using Figure 6"); $stop; end
    if (DUT.MEM.mem[1] !== 16'b011_00_000_000_00000) begin err = 1; $display("FAILED: mem[1] wrong; please set data.txt using Figure 6"); $stop; end
    if (DUT.MEM.mem[2] !== 16'b011_00_000_010_00000) begin err = 1; $display("FAILED: mem[2] wrong; please set data.txt using Figure 6"); $stop; end
    if (DUT.MEM.mem[3] !== 16'b110_00_000_011_01010) begin err = 1; $display("FAILED: mem[3] wrong; please set data.txt using Figure 6"); $stop; end
    if (DUT.MEM.mem[4] !== 16'b110_10_001_000_01001) begin err = 1; $display("FAILED: mem[4] wrong; please set data.txt using Figure 6"); $stop; end
    if (DUT.MEM.mem[5] !== 16'b011_00_001_001_00000) begin err = 1; $display("FAILED: mem[5] wrong; please set data.txt using Figure 6"); $stop; end
    if (DUT.MEM.mem[6] !== 16'b100_00_001_011_00000) begin err = 1; $display("FAILED: mem[6] wrong; please set data.txt using Figure 6"); $stop; end
    if (DUT.MEM.mem[7] !== 16'b111_00_000_000_00000) begin err = 1; $display("FAILED: mem[7] wrong; please set data.txt using Figure 6"); $stop; end
    if (DUT.MEM.mem[8] !== 16'b000_00_001_010_00000) begin err = 1; $display("FAILED: mem[8] wrong; please set data.txt using Figure 6"); $stop; end
    if (DUT.MEM.mem[9] !== 16'b000_00_001_000_00000) begin err = 1; $display("FAILED: mem[9] wrong; please set data.txt using Figure 6"); $stop; end

    @(negedge clk); // wait until next falling edge of clock

    KEY[1] = 1'b1; // reset de-asserted, PC still undefined if as in Figure 4

    #10; // waiting for RST state to cause reset of PC

    // NOTE: your program counter register output should be called PC and be inside a module with instance name CPU
    if (DUT.CPU.PC !== 9'b0) begin err = 1; $display("FAILED: PC is not reset to zero."); $stop; end

    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // wait here until PC changes; autograder expects PC set to 1 *before* executing MOV R0, X

    if (DUT.CPU.PC !== 9'h1) begin err = 1; $display("FAILED: PC should be 1."); $stop; end

    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // wait here until PC changes; autograder expects PC set to 2 *after* executing MOV R0, X

    if (DUT.CPU.PC !== 9'h2) begin err = 1; $display("FAILED: PC should be 2."); $stop; end
    if (DUT.CPU.DP.REGFILE.R0 !== 16'h8) begin err = 1; $display("FAILED: R0 should be 8."); $stop; end  // because MOV R0, X should have occurred

    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // wait here until PC changes; autograder expects PC set to 3 *after* executing LDR R1, [R0]

    if (DUT.CPU.PC !== 9'h3) begin err = 1; $display("FAILED: PC should be 3."); $stop; end
    if (DUT.CPU.DP.REGFILE.R0 !== 16'hABCD) begin err = 1; $display("FAILED: R1 should be 0xABCD. Looks like your LDR isn't working."); $stop; end

    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // wait here until PC changes; autograder expects PC set to 4 *after* executing MOV R2, Y

    if (DUT.CPU.PC !== 9'h4) begin err = 1; $display("FAILED: PC should be 4."); $stop; end
    if (DUT.CPU.DP.REGFILE.R2 !== 16'h6) begin err = 1; $display("FAILED: R2 should be 6."); $stop; end

    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // wait here until PC changes; autograder expects PC set to 5 *after* executing STR R1, [R2]
   
    if (DUT.CPU.PC !== 9'h5) begin err = 1; $display("FAILED: PC should be 5."); $stop; end
    if (DUT.MEM.mem[6] !== 16'hABCD) begin err = 1; $display("FAILED: mem[6] wrong; looks like your STR isn't working"); $stop; end

    // NOTE: if HALT is working, PC won't change again...

    if (~err) $display("INTERFACE OK");
    $stop;
  end
endmodule
