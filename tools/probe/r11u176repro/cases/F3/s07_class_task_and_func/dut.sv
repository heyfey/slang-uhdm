// § tfArgClassMethodOrder176
package p1;
  typedef enum {LOW, MED, HIGH} verb_e;
  class rep;
    task t(verb_e v);
    endtask
    function void f(input verb_e v, output verb_e w);
    endfunction
  endclass
endpackage
module top;
  import p1::*;
  rep r;
  initial r = new;
endmodule
