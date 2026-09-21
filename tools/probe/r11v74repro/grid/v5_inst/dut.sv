// v11u74 v5 — LAW B ACROSS INSTANCES.  The same module body is elaborated
// twice; each elaborated copy must point at ITS OWN namesake (clone, never
// share).  The parent's namesake must NOT be reachable from the child's
// generate scope (the walk stops at the instance body).
module leaf (output logic [31:0] o);
  logic [31:0] ns;                 // the child's own module-body namesake
  logic [31:0] only_parent_has;    // NOT declared here on purpose? it is here
  for (genvar i = 0; i < 2; i = i + 1) begin : gl
    logic [31:0] ns;
    assign ns = 32'd1;
    logic [31:0] pns;              // namesake exists ONLY in the PARENT
    assign pns = 32'd2;
  end
  assign ns = 32'd7;
  assign only_parent_has = 32'd8;
  assign o = gl[0].ns ^ gl[1].ns ^ gl[0].pns ^ ns ^ only_parent_has;
endmodule

module dut (output logic [31:0] o);
  logic [31:0] pns;                // the parent-only namesake
  logic [31:0] a, b;
  leaf u0 (.o(a));
  leaf u1 (.o(b));
  assign pns = 32'd3;
  assign o = a ^ b ^ pns;
endmodule
