// § cloneArrTsHomeElabFirst253
package p;
  class keep_c; endclass
  function automatic bit f(string a);
    string acts[];
    acts = new[2];
    foreach (acts[i]) begin
      if (acts[i] == "x") return 0;
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
