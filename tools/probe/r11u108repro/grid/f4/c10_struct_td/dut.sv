module dut (input logic [11:0] a, output logic [11:0] o);
  typedef struct packed { logic [3:0] h; logic [7:0] l; } s_t;
  function automatic logic [11:0] f(logic [11:0] x); f = s_t'(x); endfunction
  assign o = f(a);
endmodule
