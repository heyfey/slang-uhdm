// § pvHdrPortAtPortDecl305
interface ifc (o);
  output [7:0] o;
  modport mp (output o);
endinterface
module sub (ifc.mp m);
  assign m.o = 8'd1;
endmodule
module dut (output logic [7:0] o);
  ifc u_if (.o(o));
  sub u_s (.m(u_if.mp));
endmodule
