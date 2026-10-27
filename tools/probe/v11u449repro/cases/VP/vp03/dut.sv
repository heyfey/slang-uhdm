// § pkgVarArrCloneLoopVarTs449
package p;
  string s = "abc";
  function void f();
    byte b;
    foreach (s[i]) b = s[i];
  endfunction
endpackage
package r;
  import p::*;
  int k;
endpackage
module top;
  import r::*;
endmodule
