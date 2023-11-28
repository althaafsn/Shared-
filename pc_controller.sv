

module pc_controller (
    input clk,
    input reset_pc,
    input load_pc,
    output reg [8:0] pc
);

    wire [8:0] next_pc = reset_pc ? 9'd0 : pc + 1;   

    always_ff @(posedge clk) begin
        if (load_pc) begin
            pc = next_pc;
        end pc = pc;
    end

endmodule

