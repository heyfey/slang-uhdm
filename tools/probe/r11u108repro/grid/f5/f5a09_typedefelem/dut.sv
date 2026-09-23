typedef logic [1:0] w_t;
module dut #(parameter type T = w_t [3:0]) (input logic [7:0] a, output logic [7:0] o);
  T x;
  assign x = a;
  assign o = x;
endmodule
