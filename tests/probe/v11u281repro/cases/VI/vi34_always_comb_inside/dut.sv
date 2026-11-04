// § ifTpUseMultiDeclShared281v
interface ifc #(parameter type T = logic [3:0]);
  T d, q;
  always_comb q = ~d;
endinterface
module dut(input logic [3:0] i, output logic [3:0] o);
  ifc u();
  assign u.d = i;
  assign o = u.q;
endmodule
