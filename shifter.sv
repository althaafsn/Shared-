module shifter(in,shift,sout);
  input [15:0] in;
  input [1:0] shift;
  output reg [15:0] sout;
  reg [14:0] temp;

    // combinational logic block for selecting the valid mode
    always_comb begin
		temp = 14'bxxx_xxx_xxx_xxx_xxx; // temporary register.
		case (shift)
        2'b00: sout = in;
        2'b01: sout = in << 1;
        2'b10: sout = in >> 1;
        2'b11: 
        begin
            temp = in >> 1;
            sout = {in[15], temp} ;
        end
      endcase
end

endmodule


