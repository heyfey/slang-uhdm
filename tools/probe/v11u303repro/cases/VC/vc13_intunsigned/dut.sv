// § classParamNamedTypeTs303
typedef int unsigned u_t;
class C #(parameter u_t U = 7);
  int v = U;
endclass
module dut (output logic [2:0] o);
  C #() c;
  assign o = 3'b0;
endmodule
