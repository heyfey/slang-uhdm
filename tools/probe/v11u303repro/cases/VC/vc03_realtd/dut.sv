// § classParamNamedTypeTs303
typedef real r_t;
class C #(parameter r_t R = 1.5);
  real v = R;
endclass
module dut (output logic [2:0] o);
  C #() c;
  assign o = 3'b0;
endmodule
