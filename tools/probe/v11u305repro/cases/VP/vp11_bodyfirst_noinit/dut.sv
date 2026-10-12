// § pvHdrBodyFirstNdaCell305
interface ifc (o);
  wire [31:0] o;
  output [31:0] o;
  modport mp (output o);
endinterface
module sub (ifc.mp m); assign m.o = 32'd5; endmodule
module dut (output logic [31:0] o);
  ifc u_if (.o(o));
  sub u_s (.m(u_if.mp));
endmodule
