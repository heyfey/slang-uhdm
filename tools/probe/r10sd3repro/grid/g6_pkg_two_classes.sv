// g6 — TWO classes in one package, each with an out-of-body method: if the
// stamp were "the class", the two methods would name different objects; if it
// is the package home, both name the same one.
package p6;
  class c6a;
    extern function bit fa(string kind);
  endclass
  class c6b;
    extern function bit fb(string kind);
  endclass
  function bit c6a::fa(string kind);
    string loc; loc = kind; fa = (loc == "A");
  endfunction
  function bit c6b::fb(string kind);
    string loc; loc = kind; fb = (loc == "B");
  endfunction
endpackage
module top6;
  import p6::*;
  c6a ha; c6b hb;
  initial begin ha = new(); hb = new(); end
endmodule
