package p1;
  typedef enum {LOW, MED, HIGH} verb_e;
  function void report(string id, int verbosity = MED);
  endfunction
endpackage
module top;
  import p1::*;
  initial report("x");
endmodule
