// § cloneArrTsHomeElabFirst253 (an out-of-block class method, an associative local in a block)
package p;
  class c;
    extern function int f(int k);
  endclass
  function int c::f(int k);
    int n = 0;
    if (k != 0) begin
      int m[string];
      m["a"] = k;
      foreach (m[s]) n += m[s];
    end
    return n;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
