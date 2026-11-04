// § defGenPathSel161 — gen-for condition bounded by an interface port's parameter, the body targeting the port's member
interface d_if #(parameter int N = 6);
  logic [N-1:0] d;
endinterface
module sub(d_if b, input logic [5:0] a);
  for (genvar i = 0; i < b.N; i++) begin : g
    assign b.d[i] = a[i];
  end
endmodule
module top(input logic [5:0] a, output logic [5:0] o);
  d_if x();
  sub u(.b(x), .a(a));
  assign o = x.d;
endmodule
