interface IfR;
  logic [7:0] dat;
  function void ifun(int aa); dat = aa[7:0]; endfunction
  function void ifun2(int aa, int bb); dat = aa[7:0]+bb[7:0]; endfunction
endinterface
package PkR;
  class Cr #(type PT = int);
    virtual IfR vif;
    virtual IfR varr[3];
    PT tp; int kk;
    function void R1(); vif.ifun( tp.conv(kk) );          endfunction
    function void R2(); vif.ifun2( kk, tp.conv(kk) );     endfunction
    function void R3(); vif.ifun( kk );                   endfunction
    function void R4(); varr[0].ifun( tp.conv(kk) );      endfunction
  endclass
endpackage
