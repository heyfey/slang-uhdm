package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
  class K;
    row_t r;
    function new(); r = '0; endfunction
  endclass
endpackage
module dut (output logic [5:0] o);
  q2::K k;
  assign o = 6'h0;
endmodule
