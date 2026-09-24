// v11u82 w2 -- LAW B BREAK: the two candidates differ in WIDTH.  The width
// half (genCaSubstAdjustW71) is not touched by the patch, so moving the
// BINDING onto the other candidate can leave the Rhs resize answering for the
// object we no longer point at.  Both orders of the width are present.
package pc;
  wire  [31:0] w_big;   // package NET wider than the module's
  wire  [3:0]  w_small; // package NET narrower than the module's
  logic [31:0] v_big;
  logic [3:0]  v_small;
endpackage

module dut (output logic [31:0] o);
  import pc::*;
  wire  [7:0] w_big;
  wire  [7:0] w_small;
  logic [7:0] v_big;
  logic [7:0] v_small;
  for (genvar i = 0; i < 1; i = i + 1) begin : gv
    logic [11:0] w_big;   assign w_big   = 12'd1;
    logic [11:0] w_small; assign w_small = 12'd2;
    logic [11:0] v_big;   assign v_big   = 12'd3;
    logic [11:0] v_small; assign v_small = 12'd4;
  end
  assign o = {20'd0, gv[0].w_big ^ gv[0].w_small ^ gv[0].v_big ^ gv[0].v_small};
endmodule
