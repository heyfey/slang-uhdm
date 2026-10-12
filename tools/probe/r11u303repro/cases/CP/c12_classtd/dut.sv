// § classParamNamedTypeTs303
class B;
  typedef logic [2:0] t_t;
endclass
class C #(parameter B::t_t M = 3'b010);
  logic [2:0] v = M;
endclass
module dut (output logic o);
  C c;
  assign o = 1'b0;
endmodule
