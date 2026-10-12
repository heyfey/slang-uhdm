// § pkgVarLvalueScopeSep292
package q;
  int qi = 3;
endpackage
package p;
  virtual class c;
    extern function void h();
    pure virtual function void v();
  endclass
  function void c::h();
    q::qi = 9;
  endfunction
endpackage
module top; initial begin end endmodule
