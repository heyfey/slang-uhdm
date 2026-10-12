// § classParamNamedTypeTs303
typedef int arr_t [2];
class C #(parameter arr_t A = '{1, 2});
  int v = A[0];
endclass
module dut (output logic [2:0] o);
  C #() c;
  assign o = 3'b0;
endmodule
