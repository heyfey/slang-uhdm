// § hpLvSelIdxNamesByPath224 § hpLvSelColumnJoin224 (a post-increment of the part select in a class method)
package p;
  typedef struct { logic [3:0] arr [4]; } s_t;
  class k;
    s_t s;
    function void f(int i);
      s.arr[i][1:0]++;
    endfunction
  endclass
endpackage
module top;
  import p::*;
  k h;
  initial begin h = new; h.f(1); end
endmodule
