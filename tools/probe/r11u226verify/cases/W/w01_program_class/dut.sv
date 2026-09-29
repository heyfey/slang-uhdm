// § enumTdLastWriter214 § enumClsWriterUnitScopeOnly219 — a class declared inside a program lists the alias, beside a module importer
package p;
  typedef enum logic [1:0] {M0, M1, M2} mode_e;
  typedef mode_e ALIAS_T;
endpackage
program prg;
  import p::*;
  class pc;
    ALIAS_T a;
    function void set(ALIAS_T v); a = v; endfunction
  endclass
  initial begin pc c = new; c.set(M1); end
endprogram
module top(output int o);
  import p::*;
  ALIAS_T s = M2;
  assign o = int'(s);
endmodule
