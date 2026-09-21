// v11u77 vf -- the NAME COLLISION face.  The hoist keys topNets under the
// PACKAGE symbol; the module declares its own objects of the same names.  A
// gen-scope namesake cell must reach the MODULE's object, not the hoisted one,
// exactly as golden does.
package pc;
  wire  [7:0] c_net;
  logic [7:0] c_var;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } cs_t;
  cs_t        c_st;
endpackage

module dut (output logic [31:0] o);
  import pc::*;
  wire  [15:0] c_net;    // the module's OWN, same name
  logic [15:0] c_var;
  cs_t         c_st;
  for (genvar i = 0; i < 1; i = i + 1) begin : gv
    logic [31:0] c_net; assign c_net = 32'd1;
    logic [31:0] c_var; assign c_var = 32'd2;
    logic [31:0] c_st;  assign c_st  = 32'd3;
  end
  assign o = gv[0].c_net ^ gv[0].c_var ^ gv[0].c_st;
endmodule
