// § tfArgClassMethodOrder176
package p1;
  typedef struct packed {int a; int b;} pair_t;
  class rep;
    extern function void put(pair_t p[]);
  endclass
  function void rep::put(pair_t p[]);
  endfunction
endpackage
module top;
  import p1::*;
  rep r;
  pair_t q[];
  initial begin r = new; r.put(q); end
endmodule
