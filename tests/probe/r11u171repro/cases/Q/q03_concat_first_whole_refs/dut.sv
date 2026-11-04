// § udpFormConcatSwallowSpans171
module ch(A, B, C);
    input [1:0] A, B;
    output [1:0] C;
    assign C = A ^ B;
endmodule
module dut(input x, y, input [1:0] b, output [1:0] c);
ch a1 ({x, y}, b, c);
endmodule
