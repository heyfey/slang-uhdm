// § hpLvSelIdxNamesByPath224
package p;
  typedef struct packed { logic [3:0][7:0] arr; logic v; } s_t;
  class c;
    s_t s;
    function void f(logic [1:0] i, logic [1:0] d);
      s.arr[i][1:0] = d;
    endfunction
  endclass
endpackage
package q;
  import p::*;
  class d extends c;
    function void g(); f(1, 2); endfunction
  endclass
endpackage
module top; endmodule
