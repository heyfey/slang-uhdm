// § pkgVarScopedNameInt449v
package p;
  string s = "abc";
  function automatic void f();
    byte b;
    foreach (p::s[i]) b = s[i];
  endfunction
endpackage
package r;
  import p::*;
  int k;
endpackage
module top;
  import r::*;
endmodule
