// § tfArgClassMethodOrder176
package p1;
  typedef enum {LOW, MED, HIGH} verb_e;
  class rep;
    function void report(verb_e v);
    endfunction
  endclass
endpackage
module top;
  import p1::*;
  verb_e v;
endmodule
