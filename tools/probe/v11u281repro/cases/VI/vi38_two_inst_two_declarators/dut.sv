// § ifTpUseMultiDeclShared281v
interface ifc #(parameter type T = logic [3:0]);
  T d, q;
  always_comb q = ~d;
endinterface
module dut(input logic [3:0] i, output logic [3:0] o, output logic [3:0] p);
  ifc u();
  ifc v();
  assign u.d = i;
  assign v.d = ~i;
  assign o = u.q;
  assign p = v.q;
endmodule
