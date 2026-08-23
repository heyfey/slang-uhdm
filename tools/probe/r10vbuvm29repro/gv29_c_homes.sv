// r10vbuvm29 arm C (VERIFIER) — HOMES arm E did not reach: a STATIC class
// method, a class in a MODULE, a program block, an interface, a GENERATE
// block (both a generate-if and a generate-for), an always_ff, a final block,
// and a package-level continuous context.
interface vc29_if;
  int  ii;
  bit  __a[];
  function automatic int ifn();
    return int'({ << bit { __a }});
  endfunction
  initial ii = int'({ << bit { __a }});
endinterface

package vc29p;
  class S;
    static int si;
    static function void sf();
      bit __a[];
      si = int'({ << bit { __a }});
    endfunction
  endclass
endpackage

program vc29prog;
  int pi;
  bit __a[];
  initial pi = int'({ << bit { __a }});
endprogram

module vc29 #(parameter int N = 2);
  import vc29p::*;
  int m1;
  bit __b[];
  logic clk;
  class Inner;
    int x;
    function void f();
      bit __a[];
      x = int'({ << bit { __a }});
    endfunction
  endclass
  generate
    if (N > 1) begin : gblk
      int gi;
      always_comb gi = int'({ << bit { __b }});
    end
    for (genvar k = 0; k < 2; k++) begin : gloop
      int gl;
      always_comb gl = int'({ << bit { __b }}) + k;
    end
  endgenerate
  always_ff @(posedge clk) m1 <= int'({ << bit { __b }});
  final m1 = int'({ << bit { __b }});
  vc29_if uif();
endmodule
