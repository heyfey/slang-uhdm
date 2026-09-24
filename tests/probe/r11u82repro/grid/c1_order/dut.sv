// r11u82 c1 -- LAW B, the SEARCH ORDER.  A gen-scope namesake whose name
// collides with a module-own declaration: which object does the producer's
// vector search answer?  The import is written BEFORE the own declarations in
// `da` and AFTER them in `db`, so source order is separated from the rule.
package pc;
  wire  [7:0] c_net;
  logic [7:0] c_var;
endpackage

module da (output logic [31:0] o);
  import pc::*;
  wire  [15:0] c_net;
  logic [15:0] c_var;
  for (genvar i = 0; i < 1; i = i + 1) begin : gv
    logic [31:0] c_net; assign c_net = 32'd1;
    logic [31:0] c_var; assign c_var = 32'd2;
  end
  assign o = gv[0].c_net ^ gv[0].c_var;
endmodule

module db (output logic [31:0] o);
  wire  [15:0] c_net;
  logic [15:0] c_var;
  import pc::*;
  for (genvar i = 0; i < 1; i = i + 1) begin : gv
    logic [31:0] c_net; assign c_net = 32'd1;
    logic [31:0] c_var; assign c_var = 32'd2;
  end
  assign o = gv[0].c_net ^ gv[0].c_var;
endmodule

module dut (output logic [31:0] o);
  logic [31:0] a, b;
  da u_a (.o(a));
  db u_b (.o(b));
  assign o = a ^ b;
endmodule
