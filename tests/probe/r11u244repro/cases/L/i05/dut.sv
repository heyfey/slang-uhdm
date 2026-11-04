// § lvHpIpsOperandChain244
package p;
  class s_t;
    bit addr[int];
    int v[4];
    logic [63:0] data;
    s_t nx;
  endclass
  class item;
    int addr;
    int k;
  endclass
  class pred;
    function void write(item rw, s_t pi);
      int z;
      foreach (pi.v[i]) pi.data[i*8+:8] = pi.v[i];
    endfunction
  endclass
endpackage
module top;
  import p::*;
  pred w;
  initial w = new();
endmodule
