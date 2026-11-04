// § tfArgClassMethodOrder176
package p1;
  typedef enum {LOW, MED, HIGH} verb_e;
  class rep;
    function void report(verb_e v);
    endfunction
  endclass
endpackage
package p2;
  function automatic int f(p1::verb_e v);
    return int'(v);
  endfunction
endpackage
module top;
  import p1::*;
  int x;
  initial x = p2::f(MED);
endmodule
