// § udpFormConcatSwallowSpans171 § udpSwallowLvalueOnly171v
module f3 (input [1:0] A, input B, input C, output Y);
  assign Y = ^A ^ B ^ C;
endmodule
module dut (input [1:0] w, input x, y, output z);
  f3 u ({w[0] & x, w[1]}, x, y);
endmodule
