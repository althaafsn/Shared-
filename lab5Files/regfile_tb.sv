


module regfile_tb();

    reg [15:0] sim_data_in;           // value to be put in write mode
    reg [2:0] sim_writenum, sim_readnum;  // writeNum: Register number to be put in; readnum: register number to read from
    reg sim_write, clk;               // write: load.
    reg [15:0] sim_data_out;     // Value to be output in read mode
    reg err;
    
    regfile DUT (sim_data_in, sim_writenum, sim_write, sim_readnum,clk, sim_data_out);

    // rising edge every 10s
    initial forever begin
        clk = 1'b0; #5;
        clk = 1'b1; #5;
    end


    initial begin
        err = 0;
        sim_write = 1'b1;

        // Test write 3 to R0
        sim_writenum = 0;
        sim_data_in = 3;
        #10;

        assert (DUT.R0 == sim_data_in) $display("Passed overwriting R0 with %d", sim_data_in);
        else begin
            $display ("FAILED Overwriting R0, expected %d but got %d", sim_data_in, DUT.R0);
            err = 1'b1;
        end 

        // Test writing 15 to R1
        sim_writenum = 1;
        sim_data_in = 15;
        #10;

        assert (DUT.R1 == sim_data_in) $display("Passed overwriting R1 with %d", sim_data_in);
        else begin
            $display ("FAILED Overwriting R1, expected %d but got %d", sim_data_in, DUT.R1);
            err = 1'b1;
        end 

        // Test write 2000 to R2
        sim_writenum = 2;
        sim_data_in = 2000;
        #10;

        assert (DUT.R2 == sim_data_in) $display("Passed overwriting R2 with %d", sim_data_in);
        else begin
            $display ("FAILED, expected %d but got %d", sim_data_in, DUT.R2);
            err = 1'b1;
        end 

        // Test write 128 to R3
        sim_writenum = 3;
        sim_data_in = 128;
        #10;

        assert (DUT.R3 == sim_data_in) $display("Passed overwriting R3 with %d", sim_data_in);
        else begin
            $display ("FAILED, expected %d but got %d", sim_data_in, DUT.R3);
            err = 1'b1;
        end 

        // Test write 50 to R4
        sim_writenum = 4;
        sim_data_in = 50;
        #10;

        assert (DUT.R4 == sim_data_in) $display("Passed overwriting R4 with %d", sim_data_in);
        else begin
            $display ("FAILED, expected %d but got %d", sim_data_in, DUT.R4);
            err = 1'b1;
        end 

        // Test write 25 to R5
        sim_writenum = 5;
        sim_data_in = 25;
        #10;

        assert (DUT.R5 == sim_data_in) $display("Passed overwriting R5 with %d", sim_data_in);
        else begin
            $display ("FAILED, expected %d but got %d", sim_data_in, DUT.R5);
            err = 1'b1;
        end 

        // Test write 250 to R6
        sim_writenum = 6;
        sim_data_in = 250;
        #10;

        assert (DUT.R6 == sim_data_in) $display("Passed overwriting R6 with %d", sim_data_in);
        else begin
            $display ("FAILED, expected %d but got %d", sim_data_in, DUT.R6);
            err = 1'b1;
        end 

        // Test write 2200 to R7
        sim_writenum = 7;
        sim_data_in = 2200;
        #10;

        assert (DUT.R7 == sim_data_in) $display("Passed overwriting R7 with %d", sim_data_in);
        else begin
            $display ("FAILED, expected %d but got %d", sim_data_in, DUT.R7);
            err = 1'b1;
        end 

        // Test reading all registers
        sim_write = 1'b0;
 

        // R0 = 3
        // R1 = 15
        // R2 = 2000
        // R3 = 128
        // R4 = 50
        // R5 = 25
        // R6 = 250
        // R7 = 2200

        #10

        //Test reading R0 with value 3
        sim_readnum = 0; #10;
        assert (sim_data_out == 3) $display("Passed reading R0 with %d", sim_data_out);
        else begin
            $display ("FAILED, expected %d but got %d", sim_data_out, DUT.R0);
            err = 1'b1;
        end 

        #10

        //Test reading R1 with value 15
        sim_readnum = 1; #10;
        assert (sim_data_out == 15) $display("Passed reading R1 with %d", sim_data_out);
        else begin
            $display ("FAILED, expected %d but got %d", sim_data_out, DUT.R1);
            err = 1'b1;
        end 

        #10

        //Test reading R2 with value 2000
        sim_readnum = 2; #10;
        assert (sim_data_out == 2000) $display("Passed reading R2 with %d", sim_data_out);
        else begin
            $display ("FAILED, expected %d but got %d", sim_data_out, DUT.R2);
            err = 1'b1;
        end 

        #10

        //Test reading R3 with value 128
        sim_readnum = 3; #10;
        assert (sim_data_out == 128) $display("Passed reading R3 with %d", sim_data_out);
        else begin
            $display ("FAILED, expected %d but got %d", sim_data_out, DUT.R3);
            err = 1'b1;
        end 

        #10

        //Test reading R4 with value 50
        sim_readnum = 4; #10;
        assert (sim_data_out == 50) $display("Passed reading R4 with %d", sim_data_out);
        else begin
            $display ("FAILED, expected %d but got %d", sim_data_out, DUT.R4);
            err = 1'b1;
        end 

        #10;

        //Test reading R5 with value 25
        sim_readnum = 5; #10;
        assert (sim_data_out == 25) $display("Passed reading R5 with %d", sim_data_out);
        else begin
            $display ("FAILED, expected %d but got %d", sim_data_out, DUT.R5);
            err = 1'b1;
        end 

        #10;

        //Test reading R6 with value 250
        sim_readnum = 6; #10;
        assert (sim_data_out == 250) $display("Passed reading R6 with %d", sim_data_out);
        else begin
            $display ("FAILED, expected %d but got %d", sim_data_out, DUT.R6);
            err = 1'b1;
        end 

        #10;

        //Test reading R7 with value 2200
        sim_readnum = 7; #10;
        assert (sim_data_out == 2200) $display("Passed reading R7 with %d", sim_data_out);
        else begin
            $display ("FAILED, expected %d but got %d", sim_data_out, DUT.R7);
            err = 1'b1;
        end 

        #10;

        //Test overwriting existing value

        sim_write = 1'b1;

        //Test writing R1 with value 18
        sim_writenum = 1;
        sim_readnum = 1;
        sim_data_in = 18;
        #10;
        
        // Check register value of R1, should be 18
        assert (DUT.R1 == sim_data_in) $display("Passed overwriting R1 with %d", sim_data_in);
        else begin
            $display ("FAILED, expected %d but got %d", sim_data_in, DUT.R1);
            err = 1'b1;
        end 

        #10

        // Check read value from R1 (after rising edge)
        assert (sim_data_out == 18) $display("Passed reading R1 with %d", sim_data_out);
        else begin
            $display ("FAILED, expected %d but got %d", sim_data_out, DUT.R1);
            err = 1'b1;
        end 

        // Test overwrite R5 if write = 0
        sim_write = 1'b0;
        sim_writenum = 5;
        sim_readnum = 5;
        sim_data_in = 20;
        #10

        //Test trying to overwrite R5 (should not overwrite)
        assert (DUT.R5 == 25) $display("Passed not overwriting R5 with %d", sim_data_in);
        else begin
            $display ("FAILED, expected %d but got %d", sim_data_in, DUT.R1);
            err = 1'b1;
        end 

        #10
        
        //Test reading R5 (before rising edge)
        assert (sim_data_out == 25) $display("Passed reading R5 with %d", sim_data_out);
        else begin
            $display ("FAILED, expected %d but got %d", sim_data_out, DUT.R1);
            err = 1'b1;
        end 

        assert (err == 0) $display ("Passed all tests");
        else $display ("FAILED");
        #210;
        $stop;
    end
endmodule

