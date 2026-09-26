// § genElseIfGateTermPath171
module dut #(parameter int P = 3) (input a, b, output c, d);
  if (P == 1) begin : n1
    assign c = a;
  end else if (P == 2) begin : n2
    assign c = b;
  end else if (P == 3) begin
    nor g (c, a, b);
    if (1) begin : inner
      xnor h (d, a, b);
    end
  end
endmodule
