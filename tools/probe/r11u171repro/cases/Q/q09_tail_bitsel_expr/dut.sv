// § udpFormConcatSwallowSpans171
module ch(A, B, C);
    input [1:0] A;
    input B;
    output C;
    assign C = A[0] ^ B;
endmodule
module dut(input [1:0] w13, input [3:0] w135, output [3:0] w141);
ch a142 ({w13[0], w13[1]}, w135[3] & w135[0], w141[2]);
endmodule
