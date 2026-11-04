// § udpFormConcatSwallowSpans171
module ch(A, B, C);
    input [1:0] A, B;
    output [1:0] C;
    assign C = A ^ B;
endmodule
module dut(input w1, w2, input [1:0] w135, output [1:0] w141);
ch a142 ({{w1}, w2}, w135, w141);
endmodule
