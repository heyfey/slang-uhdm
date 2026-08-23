// r10v103 arm b4 — INTERFACE handles, interface ARRAY elements, virtual
// interfaces, the buvm23 with-clause carve-out, and MULTIPLICITY: the SAME
// generic class is left at its DEFAULT specialisation (where `PT tp` is an
// `int` and `tp.conv(kk)` cannot bind -- the shell) AND specialised three
// times with a class that DOES carry `conv` (where the identical statement
// binds and must keep the ordinary shape).  MEASUREMENT ONLY.
interface Ifb4;
  logic [7:0] dat;
  task iput(int aa); dat = aa[7:0]; endtask
  function void ifun(int aa); dat = aa[7:0]; endfunction
endinterface

package Vb4;
  class Cv4;
    function int conv(int aa); return aa + 1; endfunction
  endclass
  class Lf4;
    int uu;
    function void put(int aa); uu = aa; endfunction
  endclass
  class Md4;
    Lf4 slot;
    function new(); slot = new(); endfunction
  endclass
  class Vif4 #(type PT = int);
    virtual Ifb4 vif;
    virtual Ifb4 varr[3];
    Md4 bo;
    PT  tp;
    int kk;
    int q[$];
    function new(); bo = new(); endfunction
    function void W1(); vif.ifun( tp.conv(kk) );        endfunction
    function void W2(); varr[1].ifun( tp.conv(kk) );    endfunction
    task         W3(); vif.iput( tp.conv(kk) );         endtask
    function void W4(); q = q.find with ( item > tp.conv(kk) ); endfunction
    function void W5(); bo.slot.put( tp.conv(kk) );     endfunction
  endclass
endpackage

module Vb4m;
  Ifb4 ifi();
  Ifb4 ifa[3]();
  Vb4::Vif4 #(Vb4::Cv4) h1;
  Vb4::Vif4 #(Vb4::Cv4) h2;
  Vb4::Vif4 #(Vb4::Cv4) h3;
  initial begin
    ifi.iput(1);
    ifa[2].iput(2);
    h1 = new();
    h1.W5();
  end
endmodule
