// § defGenPathSel161 — gen-if condition comparing parameters of two interface ports
interface p_if #(parameter int K = 2);
  logic [K-1:0] d;
endinterface
module sub(p_if a, p_if b, output logic o);
  if (a.K == b.K) begin : eq
    assign o = 1'b1;
  end else begin : ne
    assign o = 1'b0;
  end
endmodule
module top(output logic o);
  p_if #(.K(3)) x();
  p_if #(.K(3)) y();
  sub u(.a(x), .b(y), .o(o));
endmodule
