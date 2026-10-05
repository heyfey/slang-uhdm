// § cloneTfFixedArrTsParented253 (a task with a static fixed local and a parameter-sized one)
package p;
  parameter N = 4;
  task t(int k);
    static int s[2];
    logic [3:0] w[N];
    s[0] = k;
    w[1] = k;
    foreach (w[i]) s[1] += w[i];
  endtask
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
