// v11u90 vx8 -- the interface is passed as a PORT (extra elaborated views).
interface ifc ();
  wire [31:0] w_plain = 32'd11;
  wire (strong1, weak0) [31:0] w_str = 32'd12;
  modport mp (input w_plain);
endinterface
module sub (ifc.mp p, output logic [31:0] o);
  assign o = p.w_plain;
endmodule
module dut (output logic [31:0] o);
  ifc u_if ();
  sub u_s (.p(u_if), .o(o));
endmodule
