// § classParamNamedTypeTs303
typedef bit [7:0] b_t;
class C #(parameter b_t M = 8'd9);
  int v = M;
endclass
module dut (output logic o);
  C #(8'd3) c;
  assign o = 1'b0;
endmodule
