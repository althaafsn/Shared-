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
`define ASR 2'b11

// MEMORY COMMANDS

`define MNONE 2'b00     // Does nothing to the RAM
`define MREAD 2'b01     // Reads data from RAM
`define MWRITE 2'b10    // Write data to RAM

// CLOCK DELAY
`define CLK_DELAY 5

// DEPRECATED
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

        
        /////////////////////////////////////////////////////////////////////////////////////////////////////////

                                             /* SECOND BATCH OF TESTS */

        /////////////////////////////////////////////////////////////////////////////////////////////////////////


        
        // MOV_IMM zero
        $display("\nMOV r0 #0");
        MOV_IMM(`r0, 0);
        
        // MOV_IMM negative value
        $display("\nMOV r1 #-20");
        MOV_IMM(`r1, -20);

        // Test addition 0 + -20 * 2 = -40
        $display("\nADD r2 r0 r1 LSL 1; r2 = -40");
        ALU_OP(`ADD, `r2, `r0, `r1, `L_1, -40);

        // Test ASL on MOV, on self, r2 = -40, r2/2 = -20
        $display("\nMOV r2 r2 ASR; r2 = -20");
        MOV(`r2, `r2, `ASR, -20);

        // Test addition 0 + -20 * 2 = -40
        $display("\nADD r2 r0 r1 LSL 1; r2 = -40");
        ALU_OP(`ADD, `r2, `r0, `r1, `L_1, -40);

        // ADD need negative add
        // CMP done 
        // AND shift right & shift left
        // MVN shift right & shift left


        // MOV r0 #0
        // MOV r0 #-8
        // MOV r0 r0 ASL;
        // MOV LSR
        // MVN r1 LSL
        // MVN r1 LSR
        

        // AND LSL 
        // MOV r6 #2
        $display("\nMOV r6 #2");
        MOV_IMM(`r6, 2);

        // MOV r7 #4
        $display("\nMOV r7 #4");
        MOV_IMM(`r7, 4);

        // AND r6 r7 r6 LSL #1
        $display("\nAND r6 r7 r6 LSL #1");
        ALU_OP(`AND, `r6, `r7, `r6, `L_1, 16'b0000_0000_0000_0100);

        // AND LSR
        // MOV r6 #2
        $display("\nMOV r6 #2");
        MOV_IMM(`r6, 2);

        // MOV r7 #4
        $display("\nMOV r7 #4");
        MOV_IMM(`r7, 4);

        // AND r6 r6 r7 LSR #1
        $display("\nAND r6 r6 r7 LSR #1R");
        ALU_OP(`AND, `r6, `r6, `r7, `R_1, 16'b0000_0000_0000_0010);

        // MOV r0 1
        $display("\nMOV r0 3");
        MOV_IMM(`r0, 3);
        
        $display("\nMVN r1 LSR");
        MVN(`r1, `r0, `R_1, 16'b1111_1111_1111_1110);

        $display("\nMOV r2 r1 LSR");
        MOV(`r2, `r1, `R_1, 16'b0111_1111_1111_1111);

        $display("\nMVN r2 r2 LSL");
        MVN(`r2, `r2, `L_1, 1);

        assert (err == 0) $display ("Passed all tests");
        else $display ("FAILED");

        $stop;
    end

endmodule

module cpuTest_RAM();
    
    /*
        
        @althaafsn

        TESTBENCH WORKFLOW:
        == TASK 1: test that instruction successfully loads from memory (@Kenrick-MH)
        == TASK 2: Test output is correct
        == TASK 3: Test that the next address correct.


    */

    reg clk, reset;
    reg [1:0] mem_cmd;
    reg [8:0] mem_addr;
    reg [15:0] read_data; // simulates whatever comes out of the memory;
    reg [15:0] out;

    reg [15:0] defaultMem = 16'b1101000000000111;
    reg err;

    // STATUS BITS
    reg N, V, Z;

    // registers
    wire signed [15:0] allRegs [7:0];

    assign allRegs = {DUT.DP.REGFILE.R7,
                        DUT.DP.REGFILE.R6, 
                        DUT.DP.REGFILE.R5, 
                        DUT.DP.REGFILE.R4, 
                        DUT.DP.REGFILE.R3, 
                        DUT.DP.REGFILE.R2, 
                        DUT.DP.REGFILE.R1, 
                        DUT.DP.REGFILE.R0}; 

    wire [15:0] loadedInstruction = DUT.next_instruction;

    cpu DUT (clk,reset, mem_cmd, mem_addr, read_data, out, N,V,Z);

    // clock 
    initial forever begin
        clk = 1'b0; #5;
        clk = 1'b1; #5;
    end

    initial begin
        err = 1'b0;
        read_data = 16'b0;
        reset = 1'b1;

        // Reset the CPU 
        #10;
        reset = 1'b0;

        // PC should be updated
        #10;
        
        // CPU should now query the memory
        $display ("\nTESTING ADDRESS FROM PC");
        
        // mem_addr should be 0
        assert (mem_addr == 16'h00) $display("Correct memory to read!");
        else begin
            $display("ERROR | expected 0x00 but got %h", mem_addr);
            err = 1'b1;
        end
        
        assert (mem_cmd == `MREAD) begin 
            $display("Correct command");
            read_data = defaultMem;
        end else begin
            $display("ERROR: Incorrect Commmand");
            err = 1'b1;
        end

        #10
        // Instruction is fetched, load instruction.

        #10;
        // Instruction is loaded, PC should update
        $display("\n Test if instruction is loaded properly")
        assert (loadedInstruction == read_data) $display("Instruction loaded properly");
        else begin
            $display("INSTRUCTION IS NOT LOADED");
            err = 1'b1;
        end

        #10
        // DECODE STAGE

        #10 
        // MOV IMM

        #10
        // RESULTS SHOULD BE OUT, R0 should be 7
        $display ("\nTESTING STORED VALUE");
        assert (allRegs[0] == 7) $display ("Overwrite to R0 sucessful!");
        else begin 
            $display ("Overwrite to R0 failed, got %d instead of 7", allRegs[0]);
            err = 1'b1;
        end


        assert (err == 0) $display ("Passed all tests");
        else $display ("FAILED");
        $stop;
    end

endmodule