// § cloneArrTsHomeElabFirst253
package p;
  function automatic void split(string s, ref string vals[$]);
    vals.push_back(s);
  endfunction
  class c;
    extern function bit f(string a);
  endclass
  function bit c::f(string a);
    string acts[$];
    split(a, acts);
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
