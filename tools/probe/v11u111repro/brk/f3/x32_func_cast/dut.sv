package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
  function automatic row_t f(input row_t a);
    return a ^ row_t'(6'h15);
  endfunction
endpackage
module dut (input logic [5:0] i, output logic [5:0] o);
  assign o = q2::f(q2::row_t'(i));
endmodule
