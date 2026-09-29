// § hpLvSelIdxNamesByPath224 § hpLvSelColumnJoin224 (a class parameter as the index)
package p;
  typedef struct { logic [3:0] arr [4]; } s_t;
  class k #(int P = 1);
    s_t s;
    function void f(logic [1:0] d);
      s.arr[P][1:0] = d;
    endfunction
  endclass
endpackage
module top;
  import p::*;
  k #(2) h;
  initial begin h = new; h.f(2'b01); end
endmodule
