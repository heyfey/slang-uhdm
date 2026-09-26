// § udpFormConcatSwallowSpans171 § udpSwallowLvalueOnly171v
module f3 (input [1:0] A, input B, input C, output Y);
  assign Y = ^A ^ B ^ C;
endmodule
module dut (input w, input x, y, output z);
  f3 u ({{2{w}}}, x, y);
endmodule
