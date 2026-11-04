// § hpLvSelIdxNamesByPath224 § hpLvSelColumnJoin224 (a compound assignment in a class method)
package p;
  typedef struct { logic [3:0] arr [4]; } s_t;
  class k;
    s_t s;
    function void f(int i, logic [1:0] d);
      s.arr[i][1:0] += d;
    endfunction
  endclass
endpackage
module top;
  import p::*;
  k h;
  initial begin h = new; h.f(1, 2'b01); end
endmodule
