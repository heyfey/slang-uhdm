// § cloneArrTsHomeRefOwn247
package p;
  class c;
    c succ[];
    c m_pred[c];
    extern function void f(output bit r[c]);
  endclass
  function void c::f(output bit r[c]);
    c succ[];
    succ = new[1];
    foreach (succ[s])
      foreach (succ[s].m_pred[pred])
        r[pred] = 1;
    foreach (this.succ[t]) r[this.succ[t]] = 0;
  endfunction
endpackage
module top;
  import p::*;
  c z;
endmodule
