// § genNetDeclAssignLhsShared164 — a net declaration from an interface PORT member inside a gen-if block
interface n_if;
  logic x;
endinterface
module sub(n_if p, output o);
  if (1) begin : g
    wire z = p.x;
  end
  assign o = g.z;
endmodule
module top(input a, output o);
  n_if b();
  assign b.x = a;
  sub u(.p(b), .o(o));
endmodule
