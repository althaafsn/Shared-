module regfile_tb();
    reg err = 0;
    reg clk, write;
    reg [15:0] data_in;
    reg [2:0] writenum, readnum;
    reg [15:0] data_out;

    regfile DUT(data_in, writenum, write, readnum, clk, data_out);

    initial forever begin
        clk = 0; #5;
        clk = 1; #5;
    end

    initial begin
        //Try writing 18 to R2
        data_in = 16'b0_000_000_000_001_010;
        writenum = 3'b010;
        write = 1;
        #10;

        if (DUT.R2 !== 16'b0_000_000_000_001_010) begin
            $display("R2 is not properly updated!");
            err = 1;
        end

        //Try write 20 to R7 and read R2

        data_in = 16'b0_000_000_000_010_100;
        readnum = 3'b010;
        writenum = 3'b111;
        #10;
        if (DUT.R7 !== 16'b0_000_000_000_010_100) begin
            $display("R7 is not properly updated!");
            err = 1;
        end

        if (data_out !== 16'b0_000_000_000_001_010) begin
            $display("Reading error, R2 contains wrong value!");
            err = 1;
        end

        //Try overwriting R2 with 1 and read the value of R7
        data_in = 16'h1;
        writenum = 3'b010;
        readnum = 3'b111;
        #10;

        if(DUT.R2 !== 16'h1) begin
            $display("Overwriting R2 failed");
            err = 1;
        end
        if (data_out !== 16'b0_000_000_000_010_100) begin
            $display("R7 contains wrong value");
            err = 1;
        end

        if (err == 0) begin
            $display("All tests passed!");
        end
        else $display("Failed");
        $stop;




    end



endmodule