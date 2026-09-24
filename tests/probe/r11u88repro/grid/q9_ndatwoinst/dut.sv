// r11u88 q9 -- LAW A x TWO instances of one interface: each elaborated view
// lists its OWN net-decl-assign cells (a per-view clone, not a shared one).
interface ifc ();
  wire [31:0] w_nd = 32'd11;
endinterface

module dut (output logic [31:0] o);
  ifc u_a ();
  ifc u_b ();
  assign o = u_a.w_nd ^ u_b.w_nd;
endmodule
