// § tfArgClassMethodOrder176
package p1;
  typedef struct packed {int a; int b;} pair_t;
  function int put(pair_t p); return 0;
  endfunction
endpackage
module top;
  import p1::*;
  pair_t q;
endmodule
