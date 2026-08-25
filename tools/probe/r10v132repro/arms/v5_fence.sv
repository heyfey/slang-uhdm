`include "v_defs.svh"
// the FENCES, every one written inside a PASTED invocation.
`define V_THIS_RESIZE(ARG,VAL) \
  this.ARG.push_back(VAL); \

`define V_SUP_RESIZE(ARG,VAL) \
  super.ARG.push_back(VAL); \

`define V_SCOPE_RESIZE(ARG,VAL) \
  pkg_v5132::qscope132.push_back(VAL); \

`define V_FPASTE(TYPE,ARG,V) \
  begin \
    `V_``TYPE``_RESIZE(ARG,V) \
  end \

package pkg_v5132;
  string qscope132[$];
  class base_v5132;
    string qbase132[$];
  endclass
  class cls_v5132 extends base_v5132;
    string qthis132[$];
    function void run_v5132();
      `V_FPASTE(THIS, qthis132, "a")
      `V_FPASTE(SUP, qbase132, "b")
      `V_FPASTE(SCOPE, qscope132, "c")
    endfunction
  endclass
endpackage
module top_v5132;
  import pkg_v5132::*;
  cls_v5132 c_v5132;
  initial begin
    c_v5132 = new();
    c_v5132.run_v5132();
  end
endmodule
