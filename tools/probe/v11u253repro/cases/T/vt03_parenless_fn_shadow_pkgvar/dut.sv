// § cloneTfItemLocalOwnVar253 (a local shadowing a package variable)
package p;
  int g;
  function automatic int f;
    int g;
    g = 3;
    return g;
  endfunction
  function automatic int h;
    int k;
    k = g;
    return k;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
