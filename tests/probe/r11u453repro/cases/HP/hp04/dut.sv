// § hpPartSelParenRightEnd453
package p;
  typedef struct packed { logic [15:0] data; } pkt_s;
  function automatic logic [3:0] f(pkt_s s);
    return s.data[(3):(0)];
  endfunction
endpackage
module top;
  import p::*;
endmodule
