// § pvHdrPortDeclNetFirst305
interface ifc (a);
  input [3:0] a;
  wire [3:0] a;
  modport mp (input a);
endinterface
module sub (ifc.mp m, output logic [3:0] o); assign o = m.a; endmodule
module dut (input logic [3:0] i, output logic [3:0] o);
  ifc u_if (.a(i));
  sub u_s (.m(u_if.mp), .o(o));
endmodule
