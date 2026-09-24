typedef logic [1:0] e_t;
typedef e_t [3:0] arr_t;
module dut #(parameter type T = arr_t) (input T a, output logic [7:0] o);
  T x;
  assign x = a;
  assign o = x;
endmodule
