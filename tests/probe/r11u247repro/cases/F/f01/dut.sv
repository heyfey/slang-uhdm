// § cloneArrTsHomeRefOwn247
package p;
  class c;
    c m_pred[c];
    extern function void get(ref c s[]);
    extern function void f(output bit r[c]);
  endclass
  function void c::get(ref c s[]);
    s = new[1];
  endfunction
  function void c::f(output bit r[c]);
    bit done;
    c successors[];
    get(successors);
    foreach (successors[s])
      foreach (successors[s].m_pred[pred])
        r[pred] = 1;
  endfunction
endpackage
package q;
  import p::*;
  class u;
    function void g();
      c x;
      x = null;
    endfunction
  endclass
endpackage
module top;
  import p::*;
  import q::*;
  c z;
  u w;
  initial w = new();
endmodule
