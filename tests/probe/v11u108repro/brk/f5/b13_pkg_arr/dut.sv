package pk;
  typedef logic [1:0] e_t;
  typedef e_t [3:0] arr_t;
endpackage
module dut #(localparam type T = pk::arr_t) (input logic [7:0] a, output logic [7:0] o);
  T x;
  assign x = a;
  assign o = x;
endmodule
