// § pvHdrPortDeclNetFirst305
interface ifc (o, p);
  output [7:0] o;
  input [7:0] p;
  wire [7:0] o = 8'd1;
  wire [7:0] p;
  modport ma (output o);
  modport mb (input p, output o);
endinterface
module sa (ifc.ma m); endmodule
module sb (ifc.mb m); endmodule
module dut (output logic [7:0] o, input logic [7:0] p);
  ifc u_if (.o(o), .p(p));
  sa x (.m(u_if.ma));
  sb y (.m(u_if.mb));
endmodule
