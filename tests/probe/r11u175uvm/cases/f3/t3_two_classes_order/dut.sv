package p1;
  typedef enum {LOW, MED, HIGH} verb_e;
  class zeta;
    function void fz(verb_e vz);
    endfunction
  endclass
  class alpha;
    function void fa(verb_e va);
    endfunction
  endclass
endpackage
module top;
  import p1::*;
  zeta z; alpha a;
  initial begin z = new; a = new; z.fz(LOW); a.fa(MED); end
endmodule
