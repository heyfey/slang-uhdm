// § pvHdrPortAtPortDecl305
interface ifc (.o(x));
  output [7:0] x;
  wire [7:0] x = 8'd2;
  modport mp (output x);
endinterface
module sub (ifc.mp m);
endmodule
module dut (output logic [7:0] o);
  ifc u_if (.o(o));
  sub u_s (.m(u_if.mp));
endmodule
