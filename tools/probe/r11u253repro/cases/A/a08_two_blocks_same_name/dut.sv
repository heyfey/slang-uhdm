// § cloneArrTsHomeElabFirst253 (two blocks declare the same name)
package p;
  function automatic bit f(string a);
    if (a != "") begin
      string acts[$];
      foreach (acts[i]) acts[i] = a;
    end
    else begin
      string acts[$];
      foreach (acts[j]) acts[j] = a;
    end
    return 1;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
