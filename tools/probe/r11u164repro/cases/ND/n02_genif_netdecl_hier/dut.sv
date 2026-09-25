// § genNetDeclAssignLhsShared164 — a net declaration assignment from a hierarchical path, nested gen-if blocks
module top(input a, output o);
  if (1) begin : g
    wire x = a;
    if (1) begin : h
      wire z = g.x;
    end
  end
  assign o = g.h.z;
endmodule
