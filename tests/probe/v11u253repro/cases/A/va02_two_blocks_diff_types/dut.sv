// § cloneArrTsHomeElabFirst253 (two blocks, same-named locals of different array kinds)
package p;
  function automatic int f(int k);
    int n = 0;
    if (k > 0) begin
      int v[$];
      v.push_back(k);
      foreach (v[i]) n += v[i];
    end else begin
      int v[];
      v = new[2];
      foreach (v[i]) n += v[i];
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
