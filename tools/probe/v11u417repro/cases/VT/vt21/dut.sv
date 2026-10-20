// § foreachArrayNamesTypedef417
package p;
  typedef struct packed {logic [1:0] a;} b;
endpackage
module top;
  import p::b;
  int n;
  task t();
    int b[3];
    foreach (b[i]) n += i;
  endtask
  initial t();
endmodule
