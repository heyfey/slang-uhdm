// § genNetDeclAssignLhsShared164 — a module-level net declaration assignment (control)
module top(input a, output o);
  wire z = a;
  assign o = z;
endmodule
