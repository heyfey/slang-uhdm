// v11u88 v14 -- a MODPORT interface (the InterfaceModPort canary's shape) with
// a net-decl-assign, passed to a child.
interface ifc ();
  wire [31:0] w_nd = 32'd11;
  logic [31:0] c;
  assign c = 32'd12;
  modport mp (input w_nd, output c);
endinterface

module sub (ifc.mp s, output logic [31:0] y);
  assign y = s.w_nd;
endmodule

module dut (output logic [31:0] o);
  ifc u_if ();
  sub u_s (.s(u_if.mp), .y(o));
endmodule
