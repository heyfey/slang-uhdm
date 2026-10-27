// § clsBodyCallBindsHomeTopTf446
package p;
  typedef struct { int a; byte b; } s_t;
  function automatic int use_s(s_t v);
    return v.a;
  endfunction
endpackage
package q;
  import p::*;
  class C;
    s_t m;
    function int f();
      return use_s(m);
    endfunction
  endclass
endpackage
module top;
  import q::*;
  C c;
endmodule
