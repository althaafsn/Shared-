`define S_WAIT 4'b0000
`define S_DECODE 4'b0001
`define S_WriteImm 4'b0010
`define S_GetA 4'b0011
`define S_GetB 4'b0100
`define S_ALU 4'b0101
`define S_WriteReg 4'b0110
`define S_COMP 4'b0111

`define VSEL_C 2'b00
`define VSEL_PC 2'b01
`define VSEL_IMM 2'b10
`define VSEL_MDATA 2'b11

`define SEL_D 3'b100
`define SEL_N 3'b010
`define SEL_M 3'b001

module StateController(
    input [2:0] opcode,
    input [1:0] op,
    input clk, rst, s,
    output reg loadc, loads, loada, loadb, w, write,
    output reg [2:0] nsel,
    output reg [1:0] vsel, sel
    );

    /*
        sel - select which value to load.
        selB   selA
          1     0   
    */

    /*
        loads - loader control
          3     2     1     0
        loads loadc loadb loada
    */

    /*
        nsel (one hot) - select register
         2   1   0
         Rd  Rm  Rn
    */
   
   
    reg [3:0] currentState;
    reg [3:0] allLoad;
    
    assign {loads, loadc, loadb, loada} = allLoad;
    assign {selB, selA} = sel;
    
    // STATE TRANSITIONS
    // NOTE: loads run on the next rising edge of clock
    always_ff @(posedge clk) begin
        if (rst) begin
            currentState = `S_WAIT;
        end else         
        
        case(currentState)
            
            // Only proceed if s is 1, else return to wait
            `S_WAIT: 
            begin
                if (s) begin
                    currentState = `S_DECODE;
                end else currentState = `S_WAIT;
            end

            // Now branching, 
            `S_DECODE: 
            begin
                if (opcode == 3'b110
                && op == 2'b10) begin
                    currentState = `S_WriteImm;
                end else if (opcode == 3'b101 || 
                            (opcode == 3'b110 && op == 2'b00)) begin
                    currentState = `S_GetA;
                end else currentState = `S_WAIT; 
            end

            `S_GetA:
            begin 
                currentState = `S_GetB; 
            end 

            `S_GetB:
            begin
                if (opcode == 3'b101) begin
                    if (op == 2'b01) begin
                        currentState = `S_COMP;
                    end else begin
                        currentState = `S_ALU;
                    end

                end else if (opcode == 3'b110) begin
                    if (op == 2'b00) begin
                        currentState = `S_ALU;
                    end else currentState = `S_WAIT;
                end else currentState = `S_WAIT;
                
                
                // if (opcode == 3'b101 
                //     || (opcode == 3'b110 && op == 2'b00)) begin
                    
                //         currentState = `S_ALU;

                //     end else if (opcode == 3'b101 && op == 2'b01) begin
                //         currentState = `S_COMP;
                //     end else currentState = `S_WAIT;
            end 
  
            `S_ALU:
            begin
                currentState = `S_WriteReg;  
            end 

            `S_COMP:
            begin
                currentState = `S_WAIT;  
            end 

            `S_WriteImm:
            begin
                currentState = `S_WAIT;  
            end 

            default: 
            begin
                currentState = `S_WAIT;
            end
        endcase
    end

    // DETERMINES OUTPUT OF EACH STATE
    // Output is a Mealy Machine.
    always_comb begin
        // DEFAULT VALUES
        w = 1'b0;
        allLoad = 4'b0000;
        sel = 2'b00;
        vsel = `VSEL_C;
        write = 1'b0;
		nsel = 3'b000;
        
        case (currentState)
            `S_WAIT: begin
                w = 1'b1;
            end

            // If is in the ALU state, loadC
            `S_ALU: begin
                allLoad = 4'b0100;

                // IF opcode == 3'b110 (MOV) or op = 2'b11 (MVN)
                if ((opcode == 3'b110) || (op == 2'b11)) begin
                    sel = 2'b01;
                end else sel = 2'b00;

            end  

            `S_GetA: begin
                allLoad = 4'b0001;
                nsel = `SEL_N;
            end 

            `S_GetB: begin
                allLoad = 4'b0010;
                nsel = `SEL_M;
            end 

            `S_WriteImm: begin
                nsel = `SEL_N;
                vsel = `VSEL_IMM;
                write = 1'b1;
            end 
            
            `S_WriteReg: begin
                vsel = `VSEL_C;
                write = 1'b1;
                nsel = 3'b100;
            end 

            `S_COMP: begin
                allLoad = 4'b1000;
            end

        endcase

    end




    

endmodule