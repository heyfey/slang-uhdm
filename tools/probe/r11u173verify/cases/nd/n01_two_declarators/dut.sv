// § genNetDeclAssignLhsShared164 — two declarators in one net declaration, each from a scope path
module top(input a, input b, output o, output p);
  if (1) begin : g
    wire x = a;
    wire y = b;
    if (1) begin : h
      wire z1 = g.x, z2 = g.y;
    end
  end
  assign o = g.h.z1;
  assign p = g.h.z2;
endmodule
