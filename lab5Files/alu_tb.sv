
module ALU_tb();
    reg [15:0] Ain, Bin;
    reg [1:0] ALUop;
    reg [15:0] out;
    reg Z, err;

    ALU DUT(Ain, Bin, ALUop, out, Z);

    initial begin
        err = 1'b0;
        
        // testAddtion
        ALUop = 2'b00;
        
        //Test addition 0 + 0 = 0
        Ain = 0;
        Bin = 0;

        #5;
        assert (out == 0) $display ("Addition successful");
        else begin
            $display ("FAILED addition, expected 0 but got %d", out);
            err = 1'b1;
        end 

        //Test addition 1 + 3 = 4
        Ain = 1;
        Bin = 3;

        #5;
        assert (out == 4) $display ("Addition successful");
        else begin
            $display ("FAILED addition, expected 4 but got %d", out);
            err = 1'b1;
        end 

        //Test overflow (2**15 - 1) + 1 = - 2**15
        Ain = 16'sb0111_1111_1111_1111;
        Bin = 1;

        #5;
        assert (out == 16'b1000_0000_0000_0000) $display ("Addition successful");
        else begin
            $display ("FAILED addition, expected %d but got %d", 16'b1000_0000_0000_0000, out);
            err = 1'b1;
        end 


        //Test subtraction 100 - 24 = 76
        ALUop = 2'b01;
        Ain = 100;
        Bin = 24;
    

        #5;
        assert (out == 76) $display ("Subtraction successful");
        else begin
            $display ("FAILED subtraction, expected 76 but got %d", out);
            err = 1'b1;
        end 

        //Test subtraction 0 - 0 = 0
        Ain = 0;
        Bin = 0;

        #5;
        assert (out == 0) $display ("Subtraction successful");
        else begin
            $display ("FAILED subtraction, expected 0 but got %d", out);
            err = 1'b1;
        end 

        //Test negative subtraction 0 - 1 = -1
        Ain = 0;
        Bin = 1;

        #5;
        assert (out == 16'b1111_1111_1111_1111) $display ("Subtraction successful");
        else begin
            $display ("FAILED subtraction, expected -1 but got %d", out);
            err = 1'b1;
        end

        //Test negative subtraction 0 - 1 = -1
        Ain = -2**15;
        Bin = 1;

        #5;
        assert (out == 16'b0_111_1111_1111_1111) $display ("Subtraction successful");
        else begin
            $display ("FAILED subtraction, expected 0111 1111 1111 1111 but got %b", out);
            err = 1'b1;
        end

        //BITWISE AND
        ALUop = 2'b10;
        Ain = 16'b 0000_0000_0000_0000;
        Bin = 16'b 0000_0000_0000_0000;
        
        #5;
        assert (out == 0) $display ("Bitwise AND suscessful");
        else begin
            $display ("FAILED subtraction, expected 0000 0000 0000 0000 but got %d", out);
            err = 1'b1;
        end 
        
        Ain = 16'b0110_1111_0000_0010;
        Bin = 16'b1010_0110_1100_1011;

        #5;
        assert (out == 16'b0010_0110_0000_0010) $display ("Bitwise AND suscessful");
        else begin
            $display ("FAILED subtraction, expected 0010011000000010 but got %b", out);
            err = 1'b1;
        end 
        
        //Negation 
        ALUop = 2'b11;

        //Test negation 0
        Ain = 0;
        Bin = 0;
        
        #5;
        assert (out == 16'b1_111_1111_1111_1111) $display ("Negation successful");
        else begin
            $display ("FAILED negation, expected %b but got %b", 16'b1_111_1111_1111,out);
            err = 1'b1;
        end 

        //Test negation general number
        Ain = 0;
        Bin = 16'b1_000_111_000_111_000;
        
        #5;
        assert (out == 16'b0111_0001_1100_0111) $display ("Negation successful");
        else begin
            $display ("FAILED negation, expected %b but got %b", 16'b1000_1110_0011_1000, out);
            err = 1'b1;
        end 

        //Test input Ain
        Ain = 16'b1_000_1100_0000_1000;
        Bin = 16'b1_000_1110_0011_1000;
        
        #5;
        assert (out == 16'b0111_0001_1100_0111) $display ("Negation successful");
        else begin
            $display ("FAILED negation, expected %b but got %b", 16'b0111_0001_1100_0111, out);
            err = 1'b1;
        end 

        assert (err == 0) $display ("ALl tests passed");
        else $display ("Failed");

        #440;
        $stop;
    end 

    
endmodule