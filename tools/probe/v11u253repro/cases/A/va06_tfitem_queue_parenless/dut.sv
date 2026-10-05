// § cloneArrTsHomeElabFirst253 (a paren-less function's queue local and a block queue)
package p;
  function automatic int f;
    int qq[$];
    int n;
    n = 0;
    qq.push_back(1);
    foreach (qq[i]) n += qq[i];
    begin
      int bq[$];
      bq = qq;
      foreach (bq[j]) n += bq[j];
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
