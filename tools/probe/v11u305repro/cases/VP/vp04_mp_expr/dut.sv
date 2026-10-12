// § pvHdrPortAtPortDecl305
interface ifc (o);
  output [31:0] o;
  wire [31:0] o = 32'd12;
  modport mp (output .x(o));
endinterface
module sub (ifc.mp m);
endmodule
module dut (output logic [31:0] o);
  ifc u_if (.o(o));
  sub u_s (.m(u_if.mp));
endmodule
