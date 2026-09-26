// § udpFormConcatSwallowSpans171
module ch(A, B, C);
    input [1:0] A, B;
    output [1:0] C;
    assign C = A ^ B;
endmodule
module dut(input [3:0] w13, input [1:0] s, input [1:0] w135, output [1:0] w141);
ch a142 ({w13[s], w13[1]}, w135, w141);
endmodule
