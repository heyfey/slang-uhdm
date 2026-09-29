// § hpLvSelIdxNamesByPath224
package p;
  typedef struct packed { logic [3:0][7:0] arr; logic v; } s_t;
  class k;
    s_t s; int j;
    function void f(logic [1:0] d);
      s.arr[this.j][1:0] = d;
      s.arr[j][3:2] = d;
    endfunction
  endclass
endpackage
module top; endmodule
