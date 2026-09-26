// § tfArgClassMethodOrder176
package p1;
  typedef struct packed {int a; int b;} pair_t;
  function automatic int put(pair_t p);
    return p.a;
  endfunction
endpackage
module top;
  import p1::*;
  int x;
  initial x = put('{1, 2});
endmodule
