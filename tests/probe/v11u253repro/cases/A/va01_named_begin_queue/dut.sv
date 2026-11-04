// § cloneArrTsHomeElabFirst253 (a queue in a named begin)
package p;
  function automatic bit f(string a);
    begin : nb
      string acts[$];
      acts.push_back(a);
      foreach (acts[i]) if (acts[i] == "x") return 0;
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
