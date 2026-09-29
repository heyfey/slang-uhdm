// § ipsBasePfxScopeJoin224 (an rvalue on an assignment's right side in a class task, two element selects)
package p1;
  typedef struct { logic [7:0] v; } e_t;
  class c;
    e_t arr[2][4];
    task t(int i, int j, int k, output logic [1:0] r);
      r = arr[i][j].v[k+:2];
    endtask
  endclass
endpackage
module top(output logic [1:0] o);
  import p1::*;
  c h;
  initial begin h = new; h.t(0, 1, 1, o); end
endmodule
