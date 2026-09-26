// § udpFormConcatSwallowSpans171
module ch(A, B, C);
    input [1:0] A, B;
    output [1:0] C;
    assign C = A ^ B;
endmodule
module mid(input [1:0] a, output [1:0] c);
wire [1:0] w135; wire [1:0] w141;
assign w135 = a;
ch a142 ({a[0], a[1]}, w135, w141);
assign c = w141;
endmodule
module dut(input [1:0] a, output [1:0] c);
mid m (a, c);
endmodule
