// § udpFormConcatSwallowSpans171
module ch #(parameter P = 0) (A, B, C);
    input [1:0] A, B;
    output [1:0] C;
    assign C = A ^ B;
endmodule
module dut(input [1:0] w13, input [1:0] w135, output [1:0] w141);
ch #(.P(1)) a142 ({w13[0], w13[1]}, w135, w141);
endmodule
