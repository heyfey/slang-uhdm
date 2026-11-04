package p1;
  typedef enum {LOW, MED, HIGH} verb_e;
  class rep;
    function void report(string id, verb_e v);
    endfunction
  endclass
endpackage
module top;
  import p1::*;
  rep r;
  initial begin r = new; r.report("x", MED); end
endmodule
