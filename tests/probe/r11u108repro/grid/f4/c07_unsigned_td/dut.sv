module dut (input logic [11:0] a, output logic [31:0] o);
  typedef logic [31:0] w_t;
  function automatic logic [31:0] f(logic [11:0] x); f = w_t'(x); endfunction
  assign o = f(a);
endmodule
