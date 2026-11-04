// § pvHdrPortAtPortDecl305
interface ifc (o);
  output o;
  wire o = 1'b1;
  modport mp (output o);
endinterface
module sub (ifc.mp m);
endmodule
module dut (output logic o);
  ifc u_if (.o(o));
  sub u_s (.m(u_if.mp));
endmodule
