typedef logic [1:0] e_t;
typedef logic [7:0] w_t;
module child #(parameter type T = e_t [3:0]) (output T o);
  assign o = '0;
endmodule
module dut (output logic [15:0] o);
  child #(.T(w_t [1:0])) u (.o(o));
endmodule
