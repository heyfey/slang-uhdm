// § hpPartSelParenRightEnd453
package p;
  typedef struct packed { logic [63:0] data; } pkt_s;
  function automatic logic [7:0] f(pkt_s s);
    return s.data[(7):0];
  endfunction
endpackage
module top;
  import p::*;
endmodule
