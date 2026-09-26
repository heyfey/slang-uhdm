// § udpFormConcatSwallowSpans171
module ch(A, B, C);
    input [2:0] A;
    input [1:0] B;
    output [1:0] C;
    assign C = A[1:0] ^ B;
endmodule
module dut(input [2:0] w, input [1:0] b, output [1:0] c);
ch a1 ({w[0], w[2:1]}, b, c);
endmodule
