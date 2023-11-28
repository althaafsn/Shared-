/**
*TEST BENCH FORMAT IS ADOPTED FROM AUTOGRADER
*CONTENT IS ADOPTED FROM FIGURE 8
INPUT: 10 FROM SWTICH
EXPECT: 20 DISPLAYED IN THE LED 
**/
module lab7_tb();
    reg[3:0]KEY; 
    reg[9:0]SW; 
    reg [9:0]LEDR; 
    wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    reg err = 0;

initial forever begin
    KEY[0] = 0; #5;
    KEY[0] = 1; #5;
  end

  assign clk = ~KEY[0];
    lab7_top DUT(KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5);

  initial begin
    err = 0;
    KEY[1] = 1'b0; // reset assertedory

    @(negedge clk); // wait until next falling edge of clock

    KEY[1] = 1'b1; // reset de-asserted, PC still undefined if as in Figure 4


    #10; // waiting for RST state to cause reset of PC

    // NOTE: your program counter register output should be called PC and be inside a module with instance name CPU
    if (DUT.CPU.PC !== 9'b0) begin err = 1; $display("FAILED: PC is not reset to zero."); $stop; end
    $display("OK1");


    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // wait here until PC changes; autograder expects PC set to 1 
    if (DUT.CPU.PC !== 9'h1) begin err = 1; $display("FAILED: PC should be 1."); $stop; end
    $display("OK2");
    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // wait here until PC changes; autograder expects PC set to 2 *
    //AFTER MOV R0 SW_BASE, PC MUST BE 2
    if (DUT.CPU.PC !== 9'h2) begin err = 1; $display("FAILED: PC should be 2."); $stop; end


    if (DUT.CPU.DP.REGFILE.R0 !== 16'h008) begin err = 1; $display("FAILED: R0 should be 8."); $stop; end  
    $display("OK3");
    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // wait here until PC changes; autograder expects PC set to 3 *after* executing LDR R1, [R0]
    //INPUT 10
    SW[7:0] = 8'd10;


    if (DUT.CPU.PC !== 9'h3) begin err = 1; $display("FAILED: PC should be 3."); $stop; end
//     if (DUT.CPU.DP.REGFILE.R1 !== 16'hABCD) begin err = 1; $display("FAILED: R1 should be 0xABCD. Looks like your LDR isn't working."); $stop; end
//   $display("OK4");
    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  

    if (DUT.CPU.PC !== 9'h4) begin err = 1; $display("FAILED: PC should be 4."); $stop; end
    if (DUT.CPU.DP.REGFILE.R2 !== 16'd10) begin err = 1; $display("FAILED: R2 should be 10."); $stop; end
    $display("OK5");

    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  
   
    if (DUT.CPU.PC !== 9'h5) begin err = 1; $display("FAILED: PC should be 5."); $stop; end
    if (DUT.CPU.DP.REGFILE.R3 !== 16'd20) begin err = 1; $display("R3 SHOULD CONTAIN 20"); $stop; end

    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  
    if (DUT.CPU.PC !== 9'h6) begin err = 1; $display("FAILED: PC should be 6."); $stop; end
    if (DUT.CPU.DP.REGFILE.R1 !== 16'd9) begin err = 1; $display("R1 SHOULD CONTAIN 9"); $stop; end
    $display("OK6");

    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  
    if (DUT.CPU.PC !== 9'h7) begin err = 1; $display("FAILED: PC should be 7."); $stop; end
    if (DUT.CPU.DP.REGFILE.R1 !== 16'h100) begin err = 1; $display("R1 SHOULD CONTAIN 0x100"); $stop; end

    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);
    if (DUT.CPU.PC !== 9'h8) begin err = 1; $display("FAILED: PC should be 8."); $stop; end
    if (LEDR[7:0] !== 16'd20) begin err  = 1; $display("LED IS NOT DISPLAYING CORRECTLY"); $stop; end

    if (~err) $display("INTERFACE OK");
    $stop;
  end
endmodule;