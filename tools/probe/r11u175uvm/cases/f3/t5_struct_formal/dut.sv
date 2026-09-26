package p1;
  typedef struct packed {int a; int b;} pair_t;
  class rep;
    function void put(pair_t p);
    endfunction
  endclass
endpackage
module top;
  import p1::*;
  rep r;
  initial begin r = new; r.put('{1, 2}); end
endmodule
