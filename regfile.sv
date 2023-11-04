// module registerRead(
//   input [2:0] readnum, 
//   input [15:0] R0, R1, R2, R3, R4, R5, R6, R7, 
//   output reg [15:0] data_out);
  
//   always_comb begin
//     case (readnum)
//       3'b000: data_out = R0;
//       3'b001: data_out = R1;
//       3'b010: data_out = R2;
//       3'b011: data_out = R3;
//       3'b100: data_out = R4;
//       3'b101: data_out = R5;
//       3'b110: data_out = R6;
//       3'b111: data_out = R7;
//       default: data_out = {16{1'bx}};
//     endcase 
//   end 
// endmodule

// BUGGY //
// module registerWrite(
//     input [15:0] data_in,
//     input [2:0] writenum,
//     input clk, write,
//     output reg [15:0] R0, R1, R2, R3, R4, R5, R6, R7
// );
  
//     // 1. Choose register
//     // 2. Write mode on/off
//     // 3. IF write = 1, nextRegValue = data_in
//     // 4. ELSE, nextRegValue = currentReg
//     // 5. posedge clk, update.

//     reg [127: 0] allRegisters =  {R0, R1, R2, R3, R4, R5, R6, R7};
//     reg [15:0] nextData;
//     reg [15:0] currentReg = allRegisters[writenum * 16 + 15 : writenum * 16];
  

//     always @(write) begin
//       if (write)
//         nextData = data_in;
//       else nextData = currentReg;
//     end

//     vDFF #(16) updateReg(clk, nextData, currentReg);

// endmodule

module regfile(data_in,writenum,write,readnum,clk,data_out);

  input [15:0] data_in;           // value to be put in write mode
  input [2:0] writenum, readnum;  // writeNum: Register number to be put in; readnum: register number to read from
  input write, clk;               // write: load.

  output reg [15:0] data_out;     // Value to be output in read mode
  
  reg [15:0] R7, R6, R5, R4, R3, R2, R1, R0;
  // registerRead loader (readnum, R0, R1, R2, R3, R4, R5, R6, R7, data_out);

  // WRITE DATA

    // 1. Choose register
    // 2. Write mode on/off
    // 3. IF write = 1, nextRegValue = data_in
    // 4. ELSE, nextRegValue = currentReg
    // 5. posedge clk, update.

    reg [127: 0] allRegisters =  {R7, R6, R5, R4, R3, R2, R1, R0};
    reg [15:0] nextR7, nextR6, nextR5, nextR4, nextR3, nextR2, nextR1, nextR0;

    vDFF #(16) reg0 (clk, nextR0, R0);
    vDFF #(16) reg1 (clk, nextR1, R1);
    vDFF #(16) reg2 (clk, nextR2, R2);
    vDFF #(16) reg3 (clk, nextR3, R3);
    vDFF #(16) reg4 (clk, nextR4, R4);
    vDFF #(16) reg5 (clk, nextR5, R5);
    vDFF #(16) reg6 (clk, nextR6, R6);
    vDFF #(16) reg7 (clk, nextR7, R7);

  // LOAD DATA
  always_comb begin
    case (readnum)
      3'b000: data_out = R0;
      3'b001: data_out = R1;
      3'b010: data_out = R2;
      3'b011: data_out = R3;
      3'b100: data_out = R4;
      3'b101: data_out = R5;
      3'b110: data_out = R6;
      3'b111: data_out = R7;
      default: data_out = {16{1'bx}};
    endcase   
  end 

always_comb begin
  
    {nextR7, nextR6, nextR5, nextR4, nextR3, nextR2, nextR1, nextR0} = 
      {R7,R6,R5,R4,R3,R2,R1,R0};
      
      if (write) begin   
        case (writenum)
          3'b000: nextR0 = data_in;
          3'b001: nextR1 = data_in;
          3'b010: nextR2 = data_in;
          3'b011: nextR3 = data_in;
          3'b100: nextR4 = data_in;
          3'b101: nextR5 = data_in;
          3'b110: nextR6 = data_in;
          3'b111: nextR7 = data_in;
        endcase 
      end

end




endmodule