// § foreachThisArrAtThisToken207: foreach over this.<array> in an out-of-body method, a task, a nested foreach and a two-dimensional array
package p;
class C;
  int a2[3][4];
  int q[$];
  extern function void f();
  task t(); foreach (this.q[i]) q[i]++; endtask
endclass
function void C::f();
  foreach (this.a2[i, j]) a2[i][j] = i + j;
  foreach (this.q[i]) foreach (this.q[k]) q[k] = i;
endfunction
endpackage
module top; endmodule
