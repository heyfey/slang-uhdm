// § tfArgClassMethodOrder176
package p1;
  typedef struct packed {int a; int b;} pair_t;
  task put(pair_t p);
  endtask
endpackage
module top;
  import p1::*;
  pair_t q;
endmodule
