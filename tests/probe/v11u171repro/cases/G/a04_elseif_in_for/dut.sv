// § genElseIfGateTermPath171
module dut(input [1:0] a, b, output [1:0] c);
  parameter p = 2;
  for (genvar i = 0; i < 2; i++) begin : L
    if (p == 1) begin
      and g0(c[i], a[i], b[i]);
    end else if (p == 2) begin
      xor g1(c[i], a[i], b[i]);
    end
  end
endmodule
