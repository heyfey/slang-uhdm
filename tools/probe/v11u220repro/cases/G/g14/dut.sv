// § hpVarSelColumnJoin220
package p;
  typedef struct packed { logic [3:0][7:0] arr; logic v; } s_t;
  class c;
    s_t m;
    function logic [1:0] f(int i, int k);
      return m.arr[i][k+:2];
    endfunction
    task t(int i, output logic [3:0] o);
      o = m.arr[i+1][3:0];
    endtask
  endclass
endpackage
module top; endmodule
