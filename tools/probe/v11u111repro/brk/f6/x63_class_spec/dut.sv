package pk;
  typedef logic [2:0] w_t;
  class C #(type T = logic);
    T v;
  endclass
endpackage
module dut (output logic o);
  pk::C #(pk::w_t [1:0]) c;
  assign o = 1'b0;
endmodule
