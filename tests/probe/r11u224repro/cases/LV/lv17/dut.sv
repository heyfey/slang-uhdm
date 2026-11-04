// § hpLvSelColumnJoin224
package p;
  typedef struct packed { logic [3:0][7:0] arr; logic v; } s_t;
  s_t gs;
  function automatic void f(logic [1:0] i, logic [1:0] d);
    gs.arr[i][1:0] = d;
  endfunction
endpackage
module top; endmodule
