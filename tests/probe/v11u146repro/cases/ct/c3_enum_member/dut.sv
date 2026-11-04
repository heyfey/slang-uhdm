// § classTdStructMemberPkgPath146
package p;
  typedef enum {X, Y} k_t;
  class c;
    typedef struct { k_t k; int n; } s_t;
    s_t v;
    function void f(); v.k = X; v.n = 1; endfunction
  endclass
endpackage
module top; endmodule
