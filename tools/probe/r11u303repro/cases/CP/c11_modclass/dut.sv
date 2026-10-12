// § classParamNamedTypeTs303
package q;
  typedef logic [0:2] mask_t;
endpackage
module dut (output logic o);
  class C #(parameter q::mask_t M = 3'b010);
    logic [2:0] v = M;
  endclass
  C c;
  assign o = 1'b0;
endmodule
