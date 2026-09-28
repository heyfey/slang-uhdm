// § classTdPkgEnumMemberShares209: a struct typedef with a package enum member used as a function return type
package p;
  typedef enum logic [1:0] { A, B, C } e_t;
  typedef struct packed { e_t k; logic [3:0] d; } s_t;
  function automatic s_t mk(logic [3:0] v);
    s_t r;
    r.k = B;
    r.d = v;
    return r;
  endfunction
endpackage
module top(input logic [3:0] a, output p::s_t y);
  assign y = p::mk(a);
endmodule
