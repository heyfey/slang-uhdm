// § cloneArrTsHomeRefOwn247
package p;
  class c;
    c m_pred[c];
    extern function void f(output bit r[c]);
  endclass
  function void c::f(output bit r[c]);
    c s2[];
    s2 = new[1];
    foreach (s2[s])
      foreach (s2[s].m_pred[pred])
        r[pred] = 1;
  endfunction
endpackage
module m1;
  import p::*;
  c z;
endmodule
module top;
  import p::*;
  c z;
  m1 u1();
  m1 u2();
endmodule
