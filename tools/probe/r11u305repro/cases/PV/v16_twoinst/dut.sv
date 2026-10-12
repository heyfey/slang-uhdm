// § pvHdrPortAtPortDecl305
interface ifc (o);
  output [7:0] o;
  wire [7:0] o = 8'd3;
  modport mp (output o);
endinterface
module sub (ifc.mp m);
endmodule
module dut (output logic [7:0] o, output logic [7:0] q);
  ifc u_if (.o(o));
  ifc u_jf (.o(q));
  sub u_s (.m(u_if.mp));
  sub u_t (.m(u_jf.mp));
endmodule
