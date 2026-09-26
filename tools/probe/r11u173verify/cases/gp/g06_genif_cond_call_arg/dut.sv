// § defGenPathSel161 — the interface-port parameter path as a system-call argument in a gen-if condition
interface p_if #(parameter int K = 4);
  logic [K-1:0] d;
endinterface
module sub(p_if b, output logic o);
  if ($clog2(b.K) == 2) begin : two
    assign o = 1'b1;
  end else begin : other
    assign o = 1'b0;
  end
endmodule
module top(output logic o);
  p_if x();
  sub u(.b(x), .o(o));
endmodule
