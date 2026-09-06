// r10uvm178 ARM E — THE OUT-OF-BODY CLASS METHOD INSIDE THE CLONE.
// `importPackage` clones the home package's `getTask_funcs()`, and an
// OUT-OF-BODY class method body lives in exactly that vector, so a wildcard
// importer carries a copy of it while an IN-BODY method (which lives on the
// class) is never cloned.  uvm-1.2's `uvm_object::copy` / `::compare` /
// `::sprint` and `uvm_root::report_header` are all this shape, and they are the
// rest of the corpus face this pass measures.
// The arm holds both kinds side by side plus a free function as the control.

package E_home178;
  parameter int eeMask178 = 32'h5A5A_0F0F;
  parameter string eeTag178 = "e178";

  class EK178;
    function int in_body178(input int a);      // IN-BODY: never cloned
      int r;
      r = a;
      r ^= eeMask178;
      return r;
    endfunction
    extern function int oob_xor178(input int a);
    extern function int oob_arg178(input int a);
    extern function string oob_str178();
  endclass

  function automatic int free_xor178(input int a);
    int r;
    r = a;
    r ^= eeMask178;
    return r;
  endfunction

  function int EK178::oob_xor178(input int a);   // OUT-OF-BODY: cloned
    int r;
    r = a;
    r ^= eeMask178;
    return r;
  endfunction

  function int EK178::oob_arg178(input int a);
    return free_xor178(eeMask178);               // call-argument position
  endfunction

  function string EK178::oob_str178();
    string s;
    s = eeTag178;                                // a STRING parameter
    return s;
  endfunction
endpackage

package E_imp178;
  import E_home178::*;
  function automatic int imp_own178(input int a);
    return a;
  endfunction
endpackage

module m178e (input logic clk, output int e1, e2, output string e3);
  import E_home178::*;
  import E_imp178::*;
  EK178 k;
  initial k = new();
  assign e1 = free_xor178(32'd77);
  assign e2 = imp_own178(32'd88);
  assign e3 = "x";
endmodule
