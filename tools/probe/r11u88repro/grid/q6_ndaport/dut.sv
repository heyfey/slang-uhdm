// r11u88 q6 -- LAW A x the REFERENCE-STYLE port view: an interface handed to
// a child module's interface port lists a second, reference-style view.  Does
// THAT view carry the net-decl-assign cells, or only the HOME view?
interface ifc ();
  wire [31:0] w_nd = 32'd11;
  logic [31:0] c_plain;
  assign c_plain = 32'd13;
endinterface

module sink (ifc p, output logic [31:0] o);
  assign o = p.w_nd ^ p.c_plain;
endmodule

module dut (output logic [31:0] o);
  ifc u_if ();
  sink u_s (.p(u_if), .o(o));
endmodule
