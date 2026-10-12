// § classParamNamedTypeTs303
typedef bit signed [3:0] s4_t;
class C #(parameter s4_t N = -2);
  int v = N;
endclass
module dut (output logic [2:0] o);
  C #() c;
  assign o = 3'b0;
endmodule
