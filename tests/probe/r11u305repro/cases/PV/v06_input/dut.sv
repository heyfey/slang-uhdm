// § pvHdrPortAtPortDecl305
interface ifc (i);
  input [3:0] i;
  wire [3:0] i;
  modport mp (input i);
endinterface
module sub (ifc.mp m, output logic [3:0] y);
  assign y = m.i;
endmodule
module dut (input logic [3:0] a, output logic [3:0] y);
  ifc u_if (.i(a));
  sub u_s (.m(u_if.mp), .y(y));
endmodule
