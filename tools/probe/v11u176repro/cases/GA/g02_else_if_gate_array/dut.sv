// § genElseIfGateArrayPath176
module dut #(parameter P = 2) (input [1:0] a, b, output [1:0] c);
  if (P == 1) begin
    assign c = a;
  end else if (P == 2) begin
    xor g1 [1:0] (c, a, b);
  end
endmodule
