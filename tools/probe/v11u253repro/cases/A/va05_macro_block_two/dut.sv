// § cloneArrTsHomeElabFirst253 (two block locals written by one macro: same line and column)
`define BLK(K) if (K > 0) begin int v[$]; v.push_back(K); foreach (v[i]) n += v[i]; end
package p;
  function automatic int f(int k);
    int n = 0;
    `BLK(k)
    `BLK(k)
    return n;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
