// § unitClsAggTdLastWriter235
package p;
typedef struct { string path; int offset; } slice_t;
endpackage
import p::*;
interface ifc;
endinterface
program prg;
endprogram
class env;
  slice_t s;
  function slice_t get(); return s; endfunction
endclass
module top;
  ifc i();
endmodule
