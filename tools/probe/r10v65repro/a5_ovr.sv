// v65 ARM 5 — MODULE-body localparam / PORT parameter (overridden and default)
// / genvar / literal / user function / >64-bit, in the ELAB High_conn ips
// bound.  These are the MIRROR family and the negative controls: the patch must
// leave every one of them byte-identical.  MEASUREMENT ONLY.
package pa5;
  localparam int PP = 5;
  function automatic int fw(input int x); return x; endfunction
endpackage

module l5 (input logic [63:0] a_i, input logic b_i, output logic o_o);
  assign o_o = ^a_i ^ b_i;
endmodule

module a5_ovr import pa5::*; #(
  parameter int PORTW = 5,          // port parameter, DEFAULT here
  parameter     PORTU = 5           // untyped port parameter
) (input logic [127:0] d_i, output logic [11:0] o_o);
  localparam int  LOCW = 5;         // module-body localparam, typed
  localparam      LOCU = 5;         // module-body localparam, untyped
  localparam int  LFUN = fw(5);     // folded USER FUNCTION call
  localparam logic [71:0] L72 = 72'h1_0000_0000_0000_0000;

  l5 u_locw (.a_i(d_i[0 +: LOCW ]), .b_i(d_i[0]), .o_o(o_o[0]));
  l5 u_locu (.a_i(d_i[0 +: LOCU ]), .b_i(d_i[0]), .o_o(o_o[1]));
  l5 u_porw (.a_i(d_i[0 +: PORTW]), .b_i(d_i[0]), .o_o(o_o[2]));
  l5 u_poru (.a_i(d_i[0 +: PORTU]), .b_i(d_i[0]), .o_o(o_o[3]));
  l5 u_lfun (.a_i(d_i[0 +: LFUN ]), .b_i(d_i[0]), .o_o(o_o[4]));
  l5 u_lit  (.a_i(d_i[0 +: 5    ]), .b_i(d_i[0]), .o_o(o_o[5]));
  l5 u_pkg  (.a_i(d_i[0 +: PP   ]), .b_i(d_i[0]), .o_o(o_o[6]));
  for (genvar g = 0; g < 2; g++) begin : gv
    l5 u_gv (.a_i(d_i[g*8 +: 5]), .b_i(d_i[0]), .o_o(o_o[7+g]));
  end
  assign o_o[11:9] = {L72[64], 1'b0, 1'b0};
endmodule

module a5_top (input logic [127:0] d_i, output logic [23:0] o_o);
  // the SAME module with the port parameter OVERRIDDEN, twice, two ways
  a5_ovr             u_def (.d_i(d_i), .o_o(o_o[11:0]));
  a5_ovr #(.PORTW(7), .PORTU(7)) u_ov (.d_i(d_i), .o_o(o_o[23:12]));
endmodule
