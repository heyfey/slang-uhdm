// § tfArgClassMethodOrder176
package p1;
  typedef enum {LOW, MED, HIGH} verb_e;
  class zz;
    extern function void put(verb_e v);
  endclass
  class aa;
    extern function void put(verb_e v);
  endclass
  function void aa::put(verb_e v);
  endfunction
  function void zz::put(verb_e v);
  endfunction
endpackage
module top;
  import p1::*;
  zz z; aa a;
  initial begin z = new; a = new; z.put(MED); a.put(LOW); end
endmodule
