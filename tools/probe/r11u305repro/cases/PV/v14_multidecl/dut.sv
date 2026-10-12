// § pvHdrPortAtPortDecl305
interface ifc (o, p);
  output [7:0] o, p;
  wire [7:0] o = 8'd3;
  wire [7:0] p = 8'd4;
  modport mp (output o, output p);
endinterface
module sub (ifc.mp m);
endmodule
module dut (output logic [7:0] o, output logic [7:0] q);
  ifc u_if (.o(o), .p(q));
  sub u_s (.m(u_if.mp));
endmodule
