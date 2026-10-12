// § classParamNamedTypeTs303
package q;
  typedef logic [0:2] mask_t;
  class C #(parameter mask_t M = 3'b011);
    logic [2:0] v = M;
  endclass
endpackage
module dut (output logic o);
  q::C #(3'b001) c;
  assign o = 1'b0;
endmodule
