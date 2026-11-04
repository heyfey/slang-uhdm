// § udpFormConcatSwallowSpans171
module ch2(A, C);
    input [1:0] A;
    output [1:0] C;
    assign C = ~A;
endmodule
module dut(input a, b, output [1:0] y);
  ch2 u ({a, b}, y);
endmodule
