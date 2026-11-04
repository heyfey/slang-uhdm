// § hpLvSelIdxNamesByPath224
package p;
  typedef struct packed { logic [3:0][7:0] arr; logic v; } s_t;
  class k;
    s_t s;
    function void f(logic [1:0] i, logic [1:0] d);
      s.arr[i][1:0] = d;
      this.s.arr[i][3:2] = d;
    endfunction
  endclass
endpackage
module top; endmodule
