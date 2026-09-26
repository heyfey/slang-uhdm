// § genNetDeclAssignLhsShared164 — a net declaration from a scope path in a generate block inside an interface
interface n_if;
  logic a;
  if (1) begin : g
    wire x = a;
    if (1) begin : h
      wire z = g.x;
    end
  end
endinterface
module top(input a, output o);
  n_if b();
  assign b.a = a;
  assign o = b.g.h.z;
endmodule
