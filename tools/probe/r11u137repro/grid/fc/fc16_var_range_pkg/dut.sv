// § constCallNameSpan137
package q;
  function automatic int w(input int x); return x + 1; endfunction
endpackage
module top();
  logic [q::w(3)-1:0] v;
  typedef logic [q::w(2):0] t_t;
  t_t u;
  assign v = '0;
endmodule
