// v97_c9 — the PACKAGE-ANCHORED group (pass-50 law 4, which the drain SKIPS)
// crossed with a parameterized declaring class carrying two specializations.
package p97c9;
  class tgt97c9 #(type T = int);
    T v;
  endclass
  typedef tgt97c9 #(int) anchor97c9;
  class user97c9 #(type U = int);
    typedef tgt97c9 #(int) nn97c9;
    nn97c9 h;
    U u;
  endclass
  class ui97c9 extends user97c9 #(int);
    function void f(nn97c9 p); h = p; endfunction
  endclass
  class ub97c9 extends user97c9 #(byte);
    function void f(nn97c9 p); h = p; endfunction
  endclass
endpackage
module top97c9;
endmodule
