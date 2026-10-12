// § pvHdrPortDeclNetFirst305
interface ifc (o);
  output [7:0] o;
  wire [7:0] o = 8'd5;
  modport mp (output o);
endinterface
program pg (ifc.mp m);
endprogram
module dut (output logic [7:0] o);
  ifc u_if (.o(o));
  pg p (.m(u_if.mp));
endmodule
