// § pvHdrPortDeclNetFirst305
interface ifc (o);
  output [7:0] o;
  wire [7:0] o = 8'd12;
  modport mp (output o);
endinterface
module sub (ifc.mp m);
endmodule
module dut (output logic [7:0] o, output logic [7:0] p);
  ifc u_a (.o(o));
  ifc u_b (.o(p));
  sub s_a (.m(u_a.mp));
  sub s_b (.m(u_b.mp));
endmodule
