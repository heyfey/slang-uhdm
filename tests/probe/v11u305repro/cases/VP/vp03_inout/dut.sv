// § pvHdrPortDeclNetFirst305
interface ifc (o);
  inout [7:0] o;
  wire [7:0] o;
  modport mp (inout o);
endinterface
module sub (ifc.mp m);
endmodule
module dut (inout wire [7:0] o);
  ifc u_if (.o(o));
  sub u_s (.m(u_if.mp));
endmodule
