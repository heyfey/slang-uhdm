// § lvHpIpsOperandChain244
package p;
  class item; logic [63:0] data; endclass
  class ad;
    function void bus2reg(item rw);
      for (int i = 0; i < 4; i++) rw.data[i*8 +: 8] = i;
    endfunction
  endclass
endpackage
package q; import p::*; class u; function void f(); ad x; x = null; endfunction endclass endpackage
module top; import p::*; import q::*; ad z; u w; initial w = new(); endmodule
