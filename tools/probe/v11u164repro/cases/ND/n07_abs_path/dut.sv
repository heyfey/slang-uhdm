// § genNetDeclAssignLhsShared164 — a gen-if net declaration from an absolute path through the top
module top(output wire o);
  wire x;
  if (1) begin : A
    wire z = top.x;
  end
  assign o = A.z;
endmodule
