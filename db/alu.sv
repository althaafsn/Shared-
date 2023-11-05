module ALU(Ain,Bin,ALUop,out,Z);
    input [15:0] Ain, Bin;
    input [1:0] ALUop;
    output reg [15:0] out;
    output reg Z;

    always_comb begin
        case (ALUop)
            2'b00: out = Ain + Bin;
            2'b01: out = Ain - Bin;
            2'b10: out = Ain & Bin;
            2'b11: out = ~Bin;
            default: out = 16'bx_xxx_xxx_xxx_xxx_xxx;
        endcase
        if (out == 0) begin
            Z = 1;
        end else begin
            Z = 0;
        end
    end

endmodule