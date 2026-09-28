// § enumTdLastWriter214 — the extern-method shape with a $unit class importing the package (SimpleUVM's / Scoreboard's importer is a class)
package p;
  typedef enum {M0, M1} mode_e;
  typedef mode_e ALIAS_T;
  class c;
    mode_e m;
    extern function void set(ALIAS_T val);
    extern function ALIAS_T get();
  endclass
  function void c::set(ALIAS_T val); m = val; endfunction
  function ALIAS_T c::get(); return m; endfunction
endpackage
import p::*;
class env extends c;
endclass
module top;
  env e;
endmodule
