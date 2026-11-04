// § cloneLoopVarAssocIdxTs258 (a bit-vector typedef index, bare loop list)
package p;
  typedef bit unsigned [63:0] addr_t;
  typedef logic [7:0] lb_t;
  typedef enum {A, B, C} e_t;
  class c;
    local int m[addr_t];
    extern function int f(int a);
  endclass
  function int c::f(int a);
    c top;
    int n;
    top = this;
    foreach (m[k]) begin
      if (a == 1)
        n++;
    end
    return n;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import p::*;
endmodule
