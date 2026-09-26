// § udpFormConcatSwallowSpans171
module ch(A, B, C);
    input [1:0] A, B;
    output [1:0] C;
    assign C = A ^ B;
endmodule
module mid(input [1:0] a, b, output [1:0] y);
  ch u ({a[1], b[0]}, b, y);
endmodule
module dut(input [1:0] a, b, output [1:0] y, z);
  mid m0(a, b, y);
  mid m1(b, a, z);
endmodule
