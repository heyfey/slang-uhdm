// § cloneMintParentHomeCall253
package p;
  class keep_c; endclass
  function automatic int f(int k);
    string s[4];
    int g;
    g = 1;
    s[0] = "ab";
    if (s[0].substr(g, g + 1) == "b") return 1;
    return 0;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
