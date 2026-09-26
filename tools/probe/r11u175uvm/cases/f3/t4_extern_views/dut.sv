package p1;
  typedef enum {LOW, MED, HIGH} verb_e;
  class rep;
    extern function void report(verb_e v);
  endclass
  function void rep::report(verb_e v);
  endfunction
endpackage
module top;
  import p1::*;
  rep r;
  initial begin r = new; r.report(MED); end
endmodule
