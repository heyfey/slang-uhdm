// v11u88 v4 -- LAW A SHAPE FENCE: a STRUCT net with an initializer, and the
// listing typespec's parent beside it.
typedef struct packed { logic [7:0] a; logic [7:0] b; } st_t;

interface ifc ();
  st_t s_nd = '{a: 8'd1, b: 8'd2};
  wire [31:0] w_nd = 32'd11;
endinterface

module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = {16'd0, u_if.s_nd} ^ u_if.w_nd;
endmodule
