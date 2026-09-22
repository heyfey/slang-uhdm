// v11u88 v15 -- LAW C WIDTH: the parameter's value TRUNCATED by the net, and a
// 1-bit net beside it.
interface ifc ();
  localparam int K = 300;
  localparam int ONE = 1;
  wire [7:0] w_tr = K;
  wire w_1 = ONE;
  wire [63:0] w_wide = K;
endinterface

module dut (output logic [63:0] o);
  ifc u_if ();
  assign o = {56'd0, u_if.w_tr} ^ {63'd0, u_if.w_1} ^ u_if.w_wide;
endmodule
