// § genNetDeclAssignLhsShared164 — a gen-if net declaration from a child instance's net
module ch(output wire q);
  wire n;
  assign q = n;
endmodule
module top(output wire o);
  ch u(.q());
  if (1) begin : A
    wire z = u.n;
  end
  assign o = A.z;
endmodule
