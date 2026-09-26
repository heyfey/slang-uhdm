// § udpFormConcatSwallowSpans171
module ch(A, B, C);
    input [1:0] A, B;
    output [1:0] C;
    assign C = A ^ B;
endmodule
module dut(input [1:0] w13, input [1:0] w135, output [1:0] w141);
ch a142 (.A({w13[0], w13[1]}), .B(w135), .C(w141));
endmodule
