interface Ifc5;
  logic [7:0] dat;
  function void ifun(int aa); dat = aa[7:0]; endfunction
endinterface
package Pc5;
  class Vc5;
    virtual Ifc5 vif;
    virtual Ifc5 varr[3];
    int kk;
    function void N1(); vif.ifun( kk );      endfunction
    function void N2(); varr[1].ifun( kk );  endfunction
  endclass
endpackage
