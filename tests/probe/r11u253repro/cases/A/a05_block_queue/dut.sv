// § cloneArrTsHomeElabFirst253
package p;
  function automatic bit f(string a);
    if (a != "") begin
      string acts[$];
      acts.push_back(a);
      foreach (acts[i]) begin
        if (acts[i] == "x") return 0;
      end
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
