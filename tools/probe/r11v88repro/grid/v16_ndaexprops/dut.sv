// v11u88 v16 -- OPERATION and CONCAT and CAST RHSs (not a plain NAME), and the
// fresh-Lhs rule that separates them.
interface ifc ();
  localparam int K = 5;
  wire [31:0] a = 32'd1;
  wire [31:0] b = 32'd2;
  wire [31:0] w_op = a ^ b;
  wire [31:0] w_cat = {a[15:0], b[15:0]};
  wire [31:0] w_cast = 32'(K);
  wire [31:0] w_tern = (K > 1) ? a : b;
endinterface

module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = u_if.w_op ^ u_if.w_cat ^ u_if.w_cast ^ u_if.w_tern;
endmodule
