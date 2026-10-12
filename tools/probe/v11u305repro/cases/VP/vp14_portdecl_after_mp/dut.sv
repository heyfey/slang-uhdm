// § pvHdrPortAtPortDecl305
interface ifc (o, p);
  wire [7:0] o = 8'd1;
  modport mp (output o, input p);
  output [7:0] o;
  input [7:0] p;
endinterface
module sub (ifc.mp m);
endmodule
module dut (output logic [7:0] o, input logic [7:0] p);
  ifc u_if (.o(o), .p(p));
  sub u_s (.m(u_if.mp));
endmodule
