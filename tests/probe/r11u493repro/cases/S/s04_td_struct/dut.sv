// § enumCastChainKeepsInnerCast493
module top(input int s);
  typedef struct packed { bit [1:0] a; } st_e;
  typedef logic [1:0] two_t;
  typedef int t32;
  typedef byte b_t;
  function void f(int s);
    two_t v;
    v = two_t'(st_e'(s));
  endfunction
endmodule
