// v11u74 v9 — HOW MANY HOPS DOES THE PRODUCER CLIMB?  Three nesting levels
// with a namesake at each, every target declared in the DEEPEST scope and
// every Rhs the same literal.  If golden binds m1 (module body, three scopes
// out) the walk climbs; if it binds only m3 (the immediate parent) it does
// not.
module dut (output logic [31:0] o);
  logic [31:0] m1, m2, m3;
  logic [31:0] u1;
  for (genvar i = 0; i < 1; i = i + 1) begin : L1
    logic [31:0] m2;                 // namesake TWO scopes out from L3
    if (1) begin : L2
      logic [31:0] m3;               // namesake ONE scope out from L3
      wire  [31:0] n3;               // ditto, but a NET
      if (1) begin : L3
        logic [31:0] m1; assign m1 = 32'd1;   // namesake only at module level
        logic [31:0] m2; assign m2 = 32'd2;   // namesake two scopes out
        logic [31:0] m3; assign m3 = 32'd3;   // namesake one scope out
        logic [31:0] n3; assign n3 = 32'd4;   // one scope out, a NET
      end
    end
    if (1) begin                     // UNNAMED intermediate scope
      logic [31:0] u1;               // namesake in the UNNAMED scope
      if (1) begin : L5
        logic [31:0] u1; assign u1 = 32'd5;   // one scope out, unnamed home
      end
    end
  end
  assign o = L1[0].L2.L3.m1 ^ L1[0].L2.L3.m2 ^ L1[0].L2.L3.m3
           ^ L1[0].L2.L3.n3 ^ m1 ^ m2 ^ m3 ^ u1;
endmodule
