module ALU(Ain,Bin,ALUop,out,status);
    input [15:0] Ain, Bin;
    input [1:0] ALUop;
    output reg [15:0] out;
    output [2:0] status;

    wire Z, N;
    reg V;
    assign status = {Z, V, N};
    assign Z = ~|out; 
    assign N = out[15];

    always_comb begin
        V = 1'b0;
        case (ALUop)
            2'b00: 
            begin
                out = Ain + Bin; // ADD
                V = (Ain[15] ^ out[15]) & (Bin[15] ^ out[15]);
            end 
            2'b01: 
            begin
                out = Ain - Bin; // SUB
                V = (Ain[15] ^ out[15]) & (Bin[15] ~^ out[15]);
            end 
            2'b10: out = Ain & Bin; // AND
            2'b11: out = ~Bin;
            default: out = 16'bx_xxx_xxx_xxx_xxx_xxx;
        endcase
    end

endmodule
