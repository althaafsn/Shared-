`define OPCODE_ALUOP 3'b101
`define OPCODE_MOV 3'b110

`define ADD 2'b00
`define SUB 2'b01
`define AND 2'b10
`define NEG 2'b11

// REGISTERS

`define r0 0
`define r1 1
`define r2 2
`define r3 3
`define r4 4
`define r5 5
`define r6 6
`define r7 7

`define NO_SHIFT 2'b00
`define L_1 2'b01
`define R_1 2'b10
`define R_X 2'b11

module cpuTest();

    reg [15:0] sim_in, sim_out;
    reg clk, reset, sim_s, sim_load, sim_N, sim_V, sim_Z, sim_w, err;
    
    cpu DUT(clk,reset,sim_s,sim_load,sim_in,sim_out,sim_N,sim_V,sim_Z,sim_w);

    wire signed [15:0] allRegs [7:0];
    wire [2:0] statusOut;
    wire stateWait;

    assign allRegs = {DUT.DP.REGFILE.R7,
                DUT.DP.REGFILE.R6, 
                DUT.DP.REGFILE.R5, 
                DUT.DP.REGFILE.R4, 
                DUT.DP.REGFILE.R3, 
                DUT.DP.REGFILE.R2, 
                DUT.DP.REGFILE.R1, 
                DUT.DP.REGFILE.R0}; 

    assign statusOut = {sim_Z, sim_V, sim_N};
    assign stateWait = {sim_w};
    
    // MOV R0 50
    // MOV R1 21
    // ADD R2 R0 R1 // output should be 71                                                           
    // SUB R3 R0 R1 // output should be 29
    // AND R4 R0 R1 // 0000 0000 0011 0010 & 0000 0000 0001 0101 = 0000 0000 0001 0000 
    // LSR R4 <> R2 1 // R4 = 0000 0000 0000 1010 = 10
    // ADD R5 R2 R3 LSL 1 // R5 = R2 + 2R3 = 71 + 58 = 129 
    // SUB R6 R2 R4 LSR 1 = 71 - 35/2 = 54
    // SUB R6 R6 R6 LSL 1  = -54
    // SUB R6 R6 R6 = 0 (Z = 1)
    // MOV R7 6
    // MVN R7 R7 <>;
    // ADD R7 R7 #1
    // ADD R7 R7 #25 // R7 =  19

    // The following lines describe the binary version of the assembly code above
    // 110 10 000 00110010
    // 110 10 001 00010101
    // 101 00 000 010 00 001
    // SUB still confused
    // 101 10 000 100 00 001
    // LSR still confused
    // 101 00 010 101 01 011
    //

    task MOV_IMM;
        input [2:0] Rn;
        input [7:0] writeImm;
        reg [15:0] expectedWrite;

        // Load instructions
        sim_in = {`OPCODE_MOV, {2'b10}, Rn, writeImm};
        expectedWrite = {{11{writeImm[7]}}, writeImm};

        // Load instruction
        sim_load = 1'b1;
        #10;
        sim_load = 1'b0;

        // Check wait
        assert (stateWait == 1'b1) $display ("Is in wait state");
        else begin 
            $display ("ERROR: state is not wait");
            err = 1'b1;
        end

        // Start
        sim_s = 1'b1;
        
        // Decode state
        #10
        sim_s = 1'b0;

        assert (stateWait == 1'b0) $display ("Should not be back to wait");
        else begin 
            $display ("ERROR: Is not in wait");
            err = 1'b1;
        end
        

        // Write Imm state
        #10

        assert (stateWait == 1'b0) $display ("Should not be back to wait");
        else begin 
            $display ("ERROR: Is not in wait");
            err = 1'b1;
        end

        // BACK TO WAIT
        #10

        assert (allRegs[Rn] == expectedWrite) $display ("Overwrite to R%d sucessful!", Rn);
        else begin 
            $display ("Overwrite to R%d failed, got %d instead of %d", Rn, allRegs[Rn], expectedWrite);
            err = 1'b1;
        end

        assert (stateWait == 1) $display ("Back to state wait successful!");
        else begin 
            $display ("ERROR: state is not wait");
            err = 1'b1;
        end
    endtask

    task MOV;
        input [2:0] Rd;
        input [2:0] Rm;
        input [1:0] shift;
        input [15:0] expectedWrite;

        sim_in = {`OPCODE_MOV, {5'b00_000}, Rd, shift, Rm};

        // Load instruction
        sim_load = 1'b1;
        #10;
        sim_load = 1'b0;
        
        // Check wait
        assert (stateWait == 1'b1) $display ("Is in wait state");
        else begin 
            $display ("ERROR: state is not wait");
            err = 1'b1;
        end

        // Start
        sim_s = 1'b1;

        // NEXT : Decode state
        #10
        sim_s = 1'b0;

        assert (stateWait == 1'b0) $display ("Should not be back to wait");
        else begin 
            $display ("ERROR: Is not in wait");
            err = 1'b1;
        end

        // NEXT: getA state
        #10

        assert (stateWait == 1'b0) $display ("Should not be back to wait");
        else begin 
            $display ("ERROR: Is not in wait");
            err = 1'b1;
        end

        //  NEXT: getB state
        #10

        assert (stateWait == 1'b0) $display ("Should not be back to wait");
        else begin 
            $display ("ERROR: Is not in wait");
            err = 1'b1;
        end

        // NEXT: ALU state
        #10

        assert (stateWait == 1'b0) $display ("Should not be back to wait");
        else begin 
            $display ("ERROR: Is not in wait");
            err = 1'b1;
        end

        // NEXT: WriteReg state
        #10

        assert (stateWait == 1'b0) $display ("Should not be back to wait");
        else begin 
            $display ("ERROR: Is not in wait");
            err = 1'b1;
        end

        // NEXT: Wait state
        #10

        assert (allRegs[Rd] == expectedWrite) $display ("Overwrite to R%d sucessful!", Rd);
        else begin 
            $display ("Overwrite to R%d failed, got %d instead of %d", Rd, allRegs[Rd], expectedWrite);
            err = 1'b1;
        end    

        assert (stateWait == 1) $display ("Back to state wait successful!");
        else begin 
            $display ("state is not wait");
            err = 1'b1;
        end
    endtask

    
    // Simulates all ALU OP except COMP
    task ALU_OP;
        input [1:0] ALUOP;
        input [2:0] Rd;
        input [2:0] Rn;
        input [2:0] Rm;
        input [1:0] shift;
        input [15:0] expectedOut;


        // Preapares Instruction
        sim_in = {`OPCODE_ALUOP, ALUOP, Rn, Rd, shift, Rm};

        // Load instruction
        sim_load = 1'b1;
        #10;
        sim_load = 1'b0;

        // Check wait
        assert (stateWait == 1'b1) $display ("Is in wait state");
        else begin 
            $display ("state is not wait");
            err = 1'b1;
        end

        // Start state machine
        sim_s = 1'b1;

        // Wait for 6 clock cycles ()

        // DECODE
        #10
        sim_s = 1'b0;

        assert (stateWait == 1'b0) $display ("Should not be in wait");
        else begin 
            $display ("ERROR: Is in waiting state");
            err = 1'b1;
        end

        // LOAD A
        #10
        assert (stateWait == 1'b0) $display ("Should not be in wait");
        else begin 
            $display ("ERROR: Is in waiting state");
            err = 1'b1;
        end

        // LOAD B
        #10
        assert (stateWait == 1'b0) $display ("Should not be in wait");
        else begin 
            $display ("ERROR: Is in waiting state");
            err = 1'b1;
        end

        // EXECUTION STATE
        #10
        assert (stateWait == 1'b0) $display ("Should not be in wait");
        else begin 
            $display ("ERROR: Is in waiting state");
            err = 1'b1;
        end

        // WRITE TO REG 
        #10
        assert (stateWait == 1'b0) $display ("Should not be in wait");
        else begin 
            $display ("ERROR: Is in waiting state");
            err = 1'b1;
        end

        // Now back in wait
        #10
        assert (stateWait == 1'b1) $display ("Should not be back to wait");
        else begin 
            $display ("ERROR: Is not in wait");
            err = 1'b1;
        end

        // Now check for the output
        assert (sim_out == expectedOut) $display ("Operation sucessful");
        else begin
            $display ("ERROR: Results mismatch, expected %d but got %d", expectedOut, sim_out);
        end

        // Check that output is written to register
        assert (allRegs[Rd] == expectedOut) $display ("Write to Rd %d sucessful", Rd);
        else begin
            $display ("ERROR: Results mismatch, expected %d but got %d", expectedOut, allRegs[Rd]);
        end

    endtask

    task MVN;
        input [2:0] Rd;
        input [2:0] Rm;
        input [1:0] shift;
        input [15:0] expectedWrite;
        
        sim_in = {`OPCODE_ALUOP, 5'b11_000, Rd, shift, Rm};

        // Load instruction
        sim_load = 1'b1;
        #10;
        sim_load = 1'b0;
        
        // Check wait
        assert (stateWait == 1'b1) $display ("Is in wait state");
        else begin 
            $display ("state is not wait");
            err = 1'b1;
        end

        // Start
        sim_s = 1'b1;
    
        // Decode state
        #10
        sim_s = 1'b0;

        assert (stateWait == 1'b0) $display ("Should not be back to wait");
        else begin 
            $display ("ERROR: Is not in wait");
            err = 1'b1;
        end

        // getA state
        #10

        assert (stateWait == 1'b0) $display ("Should not be back to wait");
        else begin 
            $display ("ERROR: Is not in wait");
            err = 1'b1;
        end

        // getB state
        #10

        assert (stateWait == 1'b0) $display ("Should not be back to wait");
        else begin 
            $display ("ERROR: Is not in wait");
            err = 1'b1;
        end

        // ALU state
        #10

        assert (stateWait == 1'b0) $display ("Should not be back to wait");
        else begin 
            $display ("ERROR: Is not in wait");
            err = 1'b1;
        end

        // WriteReg state
        #10

        assert (stateWait == 1'b0) $display ("Should not be back to wait");
        else begin 
            $display ("ERROR: Is not in wait");
            err = 1'b1;
        end


        // Wait state
        #10

        assert (allRegs[Rd] == expectedWrite) $display ("Overwrite to R%d sucessful!", Rd);
        else begin 
            $display ("Overwrite to R%d failed, got %b instead of %b", Rd, allRegs[Rd], expectedWrite);
            err = 1'b1;
        end

        assert (stateWait == 1) $display ("Back to state wait successful!");
        else begin 
            $display ("state is not wait");
            err = 1'b1;
        end
    endtask 


    task CMP;
        input [2:0] Rn;
        input [2:0] Rm;
        input [1:0] shift;
        input [2:0] expectedStatus;    
    
        sim_in = {`OPCODE_ALUOP, 2'b01, Rn, 3'b000, shift, Rm};

        // Load instruction
        sim_load = 1'b1;
        #10;
        sim_load = 1'b0;
        
        // Check wait
        assert (stateWait == 1'b1) $display ("Is in wait state");
        else begin 
            $display ("state is not wait");
            err = 1'b1;
        end

        // Start
        sim_s = 1'b1;

        // Decode state
        #10
        sim_s = 1'b0;

        assert (stateWait == 1'b0) $display ("Should not be back to wait");
        else begin 
            $display ("ERROR: Is not in wait");
            err = 1'b1;
        end

        // getA state
        #10

        assert (stateWait == 1'b0) $display ("Should not be back to wait");
        else begin 
            $display ("ERROR: Is not in wait");
            err = 1'b1;
        end

        // getB state
        #10

        assert (stateWait == 1'b0) $display ("Should not be back to wait");
        else begin 
            $display ("ERROR: Is not in wait");
            err = 1'b1;
        end

        // Compare state
        #10

        assert (stateWait == 1'b0) $display ("Should not be back to wait");
        else begin 
            $display ("ERROR: Is not in wait");
            err = 1'b1;
        end

        // Wait state
        #10

        assert (statusOut == expectedStatus) $display ("Status is correct");
        else begin 
            $display ("ERROR: Incorrect status, expected %b but got %b", expectedStatus, statusOut);
            err = 1'b1;
        end 

        assert (stateWait == 1) $display ("Back to state wait successful!");
        else begin 
            $display ("state is not wait");
            err = 1'b1;
        end
    endtask
    

    initial forever begin
        clk = 1'b0; #5;
        clk = 1'b1; #5;
    end
    

    initial begin
        err = 1'b0;

        // r0 = 7
        $display("\nMOV r0 #7");
        MOV_IMM(`r0, 7);

        $display("\nMOV r1 #8");
        // r1 = 8
        MOV_IMM(`r1, 8);

        $display("\nADD r2 r0 r1");
        // r2 = r1 + r2 = 15
        ALU_OP(`ADD, `r2, `r0, `r1, `NO_SHIFT, 15);

        $display("\nMOV r3 r2 LSL 1");
        // r3 = r2 << 1 = 30
        MOV(`r3, `r2, `L_1, 30);

        $display("\nADD r4 r0 r3 LSR 1");
        // r4 = r0 + r3/2 = 7 + 15 = 22
        ALU_OP(`ADD, `r4, `r0, `r3, `R_1, 22);

        // r5 = r1 + 2 r0 = 8 + 14 = 22
        $display ("\nADD r5 r1 r2 LSL #1");
        ALU_OP(`ADD, `r5, `r1, `r0, `L_1, 22);

        // CMP r4 r5, ZVN = 100
        $display ("\nCMP r4 r5");
        CMP( `r4, `r5, `NO_SHIFT, 3'b100);

        // CMP r4, r1, ZVN  = 000
        $display ("\nCMP r4 r1");
        CMP( `r4, `r1, `NO_SHIFT, 3'b000);

        // CMP r1, r4, ZVN = 001
        $display ("\nCMP r1 r4");
        CMP( `r1, `r4, `NO_SHIFT, 3'b001);

        // AND r6 r1 r2
        $display ("\nAND r6 r1 r2");
        ALU_OP(`AND, `r6, `r0, `r1, `NO_SHIFT, `r0 & `r1);

        // MVN
        $display ("\nMVN r6 r1");
        MVN( `r6, `r1, `NO_SHIFT, -9);

        // Check overflow
        // r0 = 127
        $display("\nMOV r0 #127");
        MOV_IMM(`r0, 127);

        $display("\nADD r0 r0 r0");
        // r0 = r0 + r0 = 127 + 127 = 254
        ALU_OP(`ADD, `r0, `r0, `r0, `NO_SHIFT, 254);

        $display("\nADD r0 r0 r0");
        // r0 = r0 + r0 = 254 + 254 = 508
        ALU_OP(`ADD, `r0, `r0, `r0, `NO_SHIFT, 508);

        $display("\nADD r0 r0 r0");
        // r0 = r0 + r0 = 508 + 508 = 1016
        ALU_OP(`ADD, `r0, `r0, `r0, `NO_SHIFT, 1016);

        $display("\nADD r0 r0 r0");
        // r0 = r0 + r0 = 1016 + 1016 = 2032
        ALU_OP(`ADD, `r0, `r0, `r0, `NO_SHIFT, 2032);

        $display("\nADD r0 r0 r0");
        // r0 = r0 + r0 = 2032 + 2032 = 4064
        ALU_OP(`ADD, `r0, `r0, `r0, `NO_SHIFT, 4064);

        $display("\nADD r0 r0 r0");
        // r0 = r0 + r0 = 4064 + 4064 = 8128
        ALU_OP(`ADD, `r0, `r0, `r0, `NO_SHIFT, 8128);
        
        $display("\nADD r0 r0 r0");
        // r0 = r0 + r0 = 8128 + 8128 = 16256
        ALU_OP(`ADD, `r0, `r0, `r0, `NO_SHIFT, 16256);

        $display("\nADD r0 r0 r0");
        // r0 = r0 + r0 = 16256 + 16256 = 32512
        ALU_OP(`ADD, `r0, `r0, `r0, `NO_SHIFT, 32512);

        $display("\nMOV r1 r0");
        // r1 = r0 = 32512
        MOV(`r1, `r0, `NO_SHIFT, 32512);

        $display("\nADD r0 r0 r0");
        // r0 = r0 + r0 = 32512 + 32512 = 65024
        ALU_OP(`ADD, `r0, `r0, `r0, `NO_SHIFT, -512);

        // CMP r0, r1, ZVN = 011
        $display ("\nCMP r0 r1");
        CMP( `r1, `r0, `NO_SHIFT, 3'b011);

        // Check Overflow in Reverse

        // CMP r0, r1, ZVN = 011
        $display ("\nCMP r0 r1");
        CMP( `r0, `r1, `NO_SHIFT, 3'b010);

        // RESET TEST
        
        // MOV
        sim_in = 16'b11010000_01111111;
        
        // load instruction and start state machine
        sim_load = 1'b1;
        #10;
        sim_load = 1'b0;
        sim_s = 1'b1;
        #10;
        sim_s = 1'b0;

        // reset
        reset = 1'b1;
        #10;
        reset = 1'b0;
        assert (stateWait == 1) $display ("Back to state wait successful!");
        else begin 
            $display ("state is not wait");
            err = 1'b1;
        end

        // ALU
        sim_in = {`OPCODE_ALUOP, `ADD, 3'b011, 3'b011, `NO_SHIFT, 3'b011};
        
        // load instruction and start state machine
        sim_load = 1'b1;
        #10;
        sim_load = 1'b0;
        sim_s = 1'b1;
        #10;
        sim_s = 1'b0;

        // Decode
        #10;
        // Get A
        #10;
        // Get B
        #10;

        // reset
        reset = 1'b1;
        #10;
        reset = 1'b0;

        assert (stateWait == 1) $display ("Back to state wait successful!");
        else begin 
            $display ("state is not wait");
            err = 1'b1;
        end 


    
      assert (err == 0) $display ("Passed all tests");
        else $display ("FAILED");

        $stop;
    end

endmodule