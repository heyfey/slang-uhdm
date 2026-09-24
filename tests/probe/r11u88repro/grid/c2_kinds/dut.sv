// r11u82 c2 -- LAW B by KIND across the collision: the package's copy and the
// module's own differ in net-vs-variable, and one row has NO module-own
// declaration at all (the pass-75 control that must not move).
package pc;
  wire  [7:0] k_nn;   // package NET, module NET
  wire  [7:0] k_nv;   // package NET, module VARIABLE
  logic [7:0] k_vn;   // package VAR, module NET
  logic [7:0] k_vv;   // package VAR, module VARIABLE
  logic [7:0] k_only; // package VAR, NO module-own declaration
endpackage

module dut (output logic [31:0] o);
  import pc::*;
  wire  [15:0] k_nn;
  logic [15:0] k_nv;
  wire  [15:0] k_vn;
  logic [15:0] k_vv;
  for (genvar i = 0; i < 1; i = i + 1) begin : gv
    logic [31:0] k_nn;   assign k_nn   = 32'd1;
    logic [31:0] k_nv;   assign k_nv   = 32'd2;
    logic [31:0] k_vn;   assign k_vn   = 32'd3;
    logic [31:0] k_vv;   assign k_vv   = 32'd4;
    logic [31:0] k_only; assign k_only = 32'd5;
  end
  assign o = gv[0].k_nn ^ gv[0].k_nv ^ gv[0].k_vn ^ gv[0].k_vv ^ gv[0].k_only;
endmodule
