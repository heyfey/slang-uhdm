// § udpFormConcatSwallowSpans171
module ch(A, B, C);
    input [1:0] A, B;
    output [1:0] C;
    assign C = A ^ B;
endmodule
module dut(input [1:0] w13, w7, w8, output [1:0] w141);
ch a142 ({w13[0], w13[1]}, w7 & w8, w141);
endmodule
