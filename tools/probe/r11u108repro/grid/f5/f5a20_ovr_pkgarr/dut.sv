package p;
  typedef logic [1:0] w_t;
  typedef w_t [3:0] arr_t;
endpackage
module child #(parameter type T = logic [7:0]) (input T r, output logic o);
  T y;
  assign y = r;
  assign o = ^y;
endmodule
module dut (input logic [7:0] r, output logic o);
  child #(.T(p::arr_t)) u (.r(r), .o(o));
endmodule
