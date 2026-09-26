// § genNetDeclAssignLhsShared164 — a `tri` net declaration from a scope path in a gen-if block
module top(input a, output o);
  if (1) begin : g
    wire x = a;
    if (1) begin : h
      tri z = g.x;
    end
  end
  assign o = g.h.z;
endmodule
