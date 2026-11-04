// § genElseIfGateTermPath171
module dut #(parameter int P = 2) (input a, b, output c);
  if (P == 1) begin
    assign c = a;
  end else begin
    if (P == 2) begin
      and g (c, a, b);
    end
  end
endmodule
