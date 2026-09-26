// § selLhsBareDecRhsShared171
module sub #(parameter int N = 2) (output wire [7:0] c);
  if (N > 1) begin : g
    assign c[1:0] = 3;
  end
  for (genvar i = 2; i < 4; i++) begin : l
    assign c[i] = 1;
  end
  assign c[7:4] = 9;
endmodule
module dut (output wire [7:0] a, b);
  sub u1(a);
  sub #(.N(3)) u2(b);
endmodule
