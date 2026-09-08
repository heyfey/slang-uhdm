// v217 arm E — LIFETIME BITS ON A TRANSITIVE COPY (§ 209).  A package reached
// only transitively that carries an out-of-body constructor (hoisted locals)
// with a written `static` local, an automatic one, and package-scope data on
// both sides of the import item.
package pl0;
  int l0_pre;
  class cl0;
    int m;
    extern function new();
  endclass
  function cl0::new();
    int         l0_auto;
    static int  l0_static;
    logic [3:0] l0_vec;
    m = 1;
  endfunction
  int l0_post;
endpackage

package pl1;
  int l1_pre;
  import pl0::*;
  int l1_post;
  class cl1;
    int n;
    extern function new();
  endclass
  function cl1::new();
    int        l1_auto;
    static int l1_static;
    n = 2;
  endfunction
endpackage

module vl_hop;
  import pl1::*;
  logic vl_hop_clk;
endmodule
