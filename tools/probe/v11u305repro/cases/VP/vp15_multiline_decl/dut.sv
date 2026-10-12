// § pvHdrPortDeclNetFirst305
interface ifc (a, b);
  input [3:0] a,
              b;
  wire [3:0] a;
  wire [3:0] b;
  modport mp (input a, b);
endinterface
module sub (ifc.mp m, output logic [3:0] o); assign o = m.a ^ m.b; endmodule
module dut (input logic [3:0] i, output logic [3:0] o);
  ifc u_if (.a(i), .b(i));
  sub u_s (.m(u_if.mp), .o(o));
endmodule
