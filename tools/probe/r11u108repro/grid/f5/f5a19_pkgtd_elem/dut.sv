package p;
  typedef logic [1:0] w_t;
endpackage
module dut #(parameter type id_t = p::w_t, localparam type rt_t = id_t [3:0]) (input logic [7:0] a, output logic [7:0] o);
  rt_t x;
  assign x = a;
  assign o = x;
endmodule
