// § tfArgClassMethodOrder176
package p1;
  typedef struct packed {int a; int b;} pair_t;
  function automatic int put(pair_t p[]);
    return p[0].a;
  endfunction
endpackage
module top;
  import p1::*;
  int x;
  pair_t q[];
  initial x = put(q);
endmodule
