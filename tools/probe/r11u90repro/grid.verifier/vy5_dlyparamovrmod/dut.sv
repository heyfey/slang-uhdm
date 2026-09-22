// v11u90 vy5 -- MODULE home, parameter OVERRIDDEN at instantiation, two
// instances with DIFFERENT overrides.  Clone, never share.
module sub #(parameter int D = 4) (output logic [31:0] o);
  logic [31:0] c;
  assign #D c = 32'd10;
  assign o = c;
endmodule
module dut (output logic [31:0] o);
  logic [31:0] a, b;
  sub #(.D(7)) u_a (.o(a));
  sub #(.D(9)) u_b (.o(b));
  assign o = a ^ b;
endmodule
