// § hpLvSelColumnJoin224
package p;
  typedef struct packed { logic [1:0][3:0][7:0] arr; logic v; } s_t;
  class k;
    s_t s;
    function void f(logic [1:0] i, logic j, logic [1:0] d);
      s.arr[j][i][1:0] = d;
    endfunction
  endclass
endpackage
module top; endmodule
