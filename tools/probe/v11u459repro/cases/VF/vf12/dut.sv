// § unitImpTransLateList459
package p;
  class C; endclass
  C q[$];
  function void f();
    foreach (q[i]) q[i] = null;
  endfunction
endpackage
package r;
  import p::*;
  int k;
endpackage
package s; import r::*; endpackage
import s::*;
module top;
  import r::*;
endmodule
