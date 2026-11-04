// § pvHdrBodyFirstNdaCell305
interface ifc (o, p);
  wire [31:0] o = 32'd12;
  output [31:0] o;
  output [31:0] p;
  wire [31:0] p;
  modport mp (output o, output p);
endinterface
module sub (ifc.mp m);
endmodule
module dut (output logic [31:0] o);
  logic [31:0] q;
  ifc u_if (.o(o), .p(q));
  sub u_s (.m(u_if.mp));
endmodule
