// § genNetDeclAssignLhsShared164 — a module-level net declaration assignment from a hierarchical path (control)
module top(output wire o);
  if (1) begin : A
    wire x;
  end
  wire z = A.x;
  assign o = z;
endmodule
