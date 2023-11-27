
module shifter_tb();
    reg [15:0] in;
    reg [1:0] shift;
    reg [15:0] out;
    reg err;

    shifter DUT(in, shift, out);

    initial begin

        err = 1'b0;
        in = 16'b1111_1101_1100_1001;

        shift = 2'b00;
        #5;

        assert (out == 16'b1111_1101_1100_1001) $display("No shift passed");
        else begin
            $display("FAILED NO SHIFT, expected %b but got %b", 16'b1111_1101_1100_1001, out);
            err = 1'b1;

        end 
        
        //Testing left shift
        shift = 2'b01;
        #5;

        assert (out == 16'b1111_1011_1001_0010) $display("Left shift passed");
        else begin
            $display("FAILED LEFT SHIFT, expected %b but got %b", 16'b1111_1011_1001_0010, out);

        end 

        //Testing right shift
        shift = 2'b10;

        #5;
        assert (out == 16'b0111_1110_1110_0100) $display("Right shift passed");
        else begin
            $display("FAILED RIGHT SHIFT, expected %b but got %b", 16'b0111_1110_1110_0100, out);
        end 

        //Testing right shift and copy MSB
        shift = 2'b11;
        #5;

        assert (out == 16'b1111_1110_1110_0100) $display("Right shift and copy MSB passed");
        else begin
            $display("FAILED RIGHT SHIFT AND COPY MSB, expected %b but got %b", 16'b1111_1110_1110_0100, out);
        end 

        assert (err == 0) $display ("Passed all tests");
        else $display ("FAILED");
        #480;
        $stop;
    end

endmodule