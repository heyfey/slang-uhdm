// § udpFormConcatSwallowSpans171
module f2 (input A, input B, output Y);
  assign Y = A ^ B;
endmodule
module dut (input [1:0] w, input x, output z);
  f2 u ({w[1]}, x, z);
endmodule
