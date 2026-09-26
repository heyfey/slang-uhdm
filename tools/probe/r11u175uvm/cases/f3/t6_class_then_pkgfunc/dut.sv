package p1;
  typedef enum {LOW, MED, HIGH} verb_e;
  class rep;
    function void report(verb_e v);
    endfunction
  endclass
  function void pf(verb_e pv);
  endfunction
endpackage
module top;
  import p1::*;
  rep r;
  initial begin r = new; r.report(MED); pf(LOW); end
endmodule
