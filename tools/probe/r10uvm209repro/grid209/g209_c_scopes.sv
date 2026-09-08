// r10uvm209 grid arm C — THE OTHER SOURCE SCOPES, which must NOT move.
//  * a module's OWN variables (static, never automatic);
//  * a TASK-local and a non-`new` out-of-body FUNCTION local — CompilePackage's
//    collectObjects_ stops at paTask_body_declaration and
//    paFunction_body_declaration, so neither hoists into the package listing
//    and neither can ride an import;
//  * an IN-BODY constructor, whose locals stay in the function.
package pc209;
  class ce209;
    int n;
    function new();               // IN-BODY constructor
      ce209 ib_cls;
      int   ib_int;
      ib_cls = null;
      ib_int = 0;
      n = 0;
    endfunction
    extern function int cf209(input int a);
    extern task ct209();
  endclass
  function int ce209::cf209(input int a);   // NOT a constructor
    ce209 fn_cls;
    int   fn_int;
    fn_cls = null;
    fn_int = a;
    return fn_int;
  endfunction
  task ce209::ct209();
    ce209 tk_cls;
    int   tk_int;
    tk_cls = null;
    tk_int = 0;
  endtask
  int pc_int = 5;
endpackage

import pc209::*;

module gc209;
  ce209  mc_cls;
  int    mc_int;
  string mc_str;
  task mt209();
    ce209 mt_cls;
    int   mt_int;
    mt_cls = null;
    mt_int = 0;
  endtask
  initial $display("%0d", pc_int);
endmodule
