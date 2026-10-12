// § classParamNamedTypeTs303
class C #(type T = logic [2:0], parameter T V = 3'b010);
  T v = V;
endclass
module dut (output logic [2:0] o);
  C #() c;
  assign o = 3'b0;
endmodule
