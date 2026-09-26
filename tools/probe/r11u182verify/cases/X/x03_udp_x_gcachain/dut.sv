// § udpFormConcatSwallowSpans171 § genCaFoldTsChainNamed169
module f3 (input [1:0] A, input B, output Y);
  assign Y = ^A ^ B;
endmodule
module dut #(parameter int OFF = 1) (input [3:0] w, input x, output [2:0] z);
  for (genvar i = 0; i < 3; i++) begin : g
    f3 u ({w[i+OFF], w[i]}, x, z[i]);
  end
endmodule
