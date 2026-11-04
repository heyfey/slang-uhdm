// § hpVarSelColumnJoin220
package p;
  typedef struct packed { logic [1:0][7:0] value; logic v; } s_t;
  class m;
    function logic [7:0] f(s_t rw, int idx, int i);
      return rw.value[idx][8*i+:8];
    endfunction
  endclass
endpackage
module top; endmodule
