package pk;
  typedef logic [1:0] w_t;
endpackage
module child #(parameter type T = logic, parameter T V = '0) (output logic [3:0] o);
  assign o = V;
endmodule
module dut (output logic [3:0] o);
  child #(.T(pk::w_t [1:0]), .V(4'h5)) u (.o(o));
endmodule
