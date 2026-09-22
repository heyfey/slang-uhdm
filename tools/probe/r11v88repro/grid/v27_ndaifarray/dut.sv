// v11u88 v27 -- an interface ARRAY instance, each element listing its own
// net-decl-assign cell, plus a gen-FOR home inside the interface.
interface ifc ();
  wire [31:0] w_nd = 32'd11;
  for (genvar k = 0; k < 2; k++) begin : gk
    wire [31:0] w_g = 32'd12 + k;
  end
endinterface

module dut (output logic [31:0] o);
  ifc u[2] ();
  assign o = u[0].w_nd ^ u[1].w_nd ^ u[0].gk[0].w_g ^ u[1].gk[1].w_g;
endmodule
