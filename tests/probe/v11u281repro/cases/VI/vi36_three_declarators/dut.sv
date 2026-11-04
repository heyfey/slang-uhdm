// § ifTpUseMultiDeclShared281v
interface ifc #(parameter type T = logic [3:0]);
  T a, b, c;
  assign b = a;
  assign c = ~b;
endinterface
module dut(input logic [3:0] i, output logic [3:0] o);
  ifc u();
  assign u.a = i;
  assign o = u.c;
endmodule
