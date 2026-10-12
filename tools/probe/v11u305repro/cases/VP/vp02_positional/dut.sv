// § pvHdrPortDeclNetFirst305
interface ifc (o);
  output [31:0] o;
  wire [31:0] o = 32'd12;
  modport mp (output o);
endinterface
module sub (ifc.mp m);
endmodule
module dut (output logic [31:0] o);
  ifc u_if (o);
  sub u_s (u_if.mp);
endmodule
