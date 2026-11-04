// § ifTpUseMultiDeclShared281v
interface ifc #(parameter type T = logic [3:0]);
  T d, e;
endinterface
module dut(input logic [3:0] i, output logic [3:0] o);
  ifc u();
  assign u.d = i;
  assign u.e = u.d;
  assign o = u.e;
endmodule
