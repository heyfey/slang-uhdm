// § pvHdrPortAtPortDecl305
interface ifc (o);
  input [7:0] o;
  wire [7:0] o;
  modport mp (input o);
endinterface
module sub (ifc.mp m, output logic [7:0] y);
  assign y = m.o + 8'd1;
endmodule
module dut (input logic [7:0] a, output logic [7:0] y);
  ifc u_if (.o(a));
  sub u_s (.m(u_if.mp), .y(y));
endmodule
