// § enumTdLastWriter214 — a $unit import, a $unit class and a module after it (SimpleUVM's testbench shape)
package p;
  typedef enum {M0, M1} mode_e;
  typedef mode_e ALIAS_T;
  class c;
    mode_e m;
    function void set(ALIAS_T val); m = val; endfunction
  endclass
endpackage
import p::*;
class env;
  int x;
endclass
module top;
  env e;
endmodule
