// § udpFormConcatSwallowSpans171
module f3 (input [3:0] A, input B, input C, output Y);
  assign Y = ^A ^ B ^ C;
endmodule
module dut (input [3:0] w, input x, y, output z);
  f3 u ({w[3:2], w[1:0]}, x & y, z);
endmodule
