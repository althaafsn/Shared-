// MEMORY COMMAND
`define MNONE 2'b00     // Does nothing to the RAM
`define MREAD 2'b01     // Reads data from RAM
`define MWRITE 2'b10    // Write data to RAM

// SSEG encoding

`define ZERO        7'b1000000
`define ONE         7'b1111001 
`define TWO         7'b0100100
`define THREE       7'b0110000
`define FOUR        7'b0011001
`define FIVE        7'b0010010
`define SIX         7'b0000010
`define SEVEN       7'b1111000
`define EIGHT       7'b0000000
`define NINE        7'b0010000
`define LETTER_A    7'b0001000
`define LETTER_B    7'b0000011
`define LETTER_C    7'b1000110
`define LETTER_D    7'b0100001
`define LETTER_E    7'b0000110
`define LETTER_F    7'b0001110
`define ALL_OFF     7'b1111111

/* 
    Helper module, 

    This manages the RAM for LAB7, 

    INPUT   clk is the clock signal
    INPUT   mem_cmd is the command sent into the RAM
    INPUT   write_data is the data that is going to be weitten in the ram
    OUTPUT  read_data the data that is read from the RAM
*/ 

module Memory_Control (clk, mem_cmd, mem_addr, write_data, read_data);
    input clk;
    input [1:0] mem_cmd;

    // mem_addr is 9 bit because in stage 3 we use memory in 0x100 to 0x1FF
    input [8:0] mem_addr;
    input [15:0] write_data;
    output reg [15:0] read_data;

    reg enable_read, write;
    reg [15:0] dout;

    RAM MEM(
        .clk(clk),
        .read_address(mem_addr),
        .write_address(mem_addr),
        .write(write),
        .din(write_data),
        .dout(dout) );

    // assign write_data to a tristate driver
    assign write_data = enable_read ? dout : {16'b{1'bz}};
    
    // Combinational logic for enable_read and write.
    always_comb begin
       enable_read = (mem_cmd == `MREAD) && (mem_addr[8] == 1'b0);
       write = (mem_cmd == `MWRITE) && (mem_addr[8] == 1'b0);
    end

endmodule

module lab7_top(KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5);

    input [3:0] KEY;
    input [9:0] SW;
    output [9:0] LEDR;
    output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

    cpu(clk,reset, mem_cmd, mem_addr, read_data, out, N,V,Z);

    cpu CPU (~KEY[0], ~KEY[3], )

    reg enable_read, write;
    reg [15:0] dout;

    RAM MEM(
        .clk(clk),
        .read_address(mem_addr),
        .write_address(mem_addr),
        .write(write),
        .din(write_data),
        .dout(dout) );

    // assign write_data to a tristate driver
    assign write_data = enable_read ? dout : {16'b{1'bz}};

    // Combinational logic for enable_read and write.
    always_comb begin
        enable_read = (mem_cmd == `MREAD) && (mem_addr[8] == 1'b0);
        write = (mem_cmd == `MWRITE) && (mem_addr[8] == 1'b0);
    end



endmodule


