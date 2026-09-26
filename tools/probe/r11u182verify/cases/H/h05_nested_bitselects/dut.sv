// § udpFormConcatSwallowSpans171
module f3 (input [2:0] A, input B, input C, output Y);
  assign Y = ^A ^ B ^ C;
endmodule
module dut (input [2:0] w, input x, y, output z);
  f3 u ({{w[2], w[1]}, w[0]}, x, y);
endmodule
