// § tdAtomRetAliasTwin412
module top(output logic [31:0] o);
  typedef int i_t;
  typedef byte b_t;
  function i_t f(); return 3; endfunction
  function automatic b_t g(input b_t x); return x + 1; endfunction
  assign o = f() + g(8'd2);
endmodule
