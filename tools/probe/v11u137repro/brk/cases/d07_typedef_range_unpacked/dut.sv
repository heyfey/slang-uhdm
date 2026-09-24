// § constCallNameSpan137
module top(output logic o);
  function automatic int f(input int x); return x + 1; endfunction
  typedef logic [f(2):0] t_t;
  t_t a;
  logic b [f(1)];
  assign o = a[0] ^ b[0];
endmodule
