// r10buvm8 v1 — THE CALL-ARGUMENT TYPESPEC GRID.
//
// One cell per (callee kind x call context x argument kind), each on its OWN
// source line so the census can be joined on line:col.  Read with
// r10buvm8cen; the question every cell answers is whether GOLDEN hangs a
// ref_typespec on the ARGUMENT expression of a call.
//
// The head this pass targets is uvm_pkg.sv:9737
//   return (uvm_re_match(s, str) == 0);
// with uvm_re_match a DPI-C *context* import.  Its twin one line earlier,
//   s = uvm_glob_to_re(expr);
// also a DPI-C *context* import with a string formal, gets NOTHING — so the
// callee's DPI-ness alone is REFUTED before this file is written, and the
// cells below vary the CONTEXT and the ARGUMENT independently.

package p8;

  typedef struct packed { logic [3:0] a; logic [3:0] b; } st_t;

  // ---- callees -------------------------------------------------------------
  import "DPI-C" context function int  dpi_ctx_i (string re, string str);  // like uvm_re_match
  import "DPI-C" context function string dpi_ctx_s (string glob);          // like uvm_glob_to_re
  import "DPI-C"         function string dpi_pln_s (int init);             // like uvm_dpi_get_next_arg_c
  import "DPI-C"         function int    dpi_pln_i (string a, int b);
  import "DPI-C"         function void   dpi_pln_v (string a);

  function int sv_i (string re, string str); return 0; endfunction
  function string sv_s (string glob); return glob; endfunction
  function int sv_ii (int a, int b); return a + b; endfunction
  task sv_t (string a); endtask

  class cls;
    string cs;
    int    ci;
    function int m_i (string re, int k); return k; endfunction
    task m_t (string re); endtask
  endclass

  // ---- a1: THE HEAD SHAPE — DPI ctx int-returning, call inside a comparison
  //          inside a return, args = a local var and a formal
  function bit a1 (string expr, string str);
    string s;
    s = dpi_ctx_s(expr);                  // a1b  assignment RHS, DPI ctx string
    return (dpi_ctx_i(s, str) == 0);      // a1a  THE HEAD SHAPE
  endfunction

  // ---- a2: plain return of a DPI call (the 7594 shape)
  function string a2 (int init = 0);
    return dpi_pln_s(init);               // a2a
  endfunction

  // ---- a3: the SAME callee as a1a in OTHER contexts
  function bit a3 (string expr, string str);
    string s; int r; bit b;
    s = expr;
    r = dpi_ctx_i(s, str);                // a3a  assignment RHS
    b = (dpi_ctx_i(s, str) == 0);         // a3b  assignment RHS, in comparison
    if (dpi_ctx_i(s, str) == 0) b = 1;    // a3c  if-condition, in comparison
    if (dpi_ctx_i(s, str)) b = 1;         // a3d  if-condition, bare
    return (dpi_ctx_i(s, str) != 1);      // a3e  return, comparison, != instead of ==
  endfunction

  function bit a4 (string expr, string str);
    string s; s = expr;
    return (dpi_ctx_i(s, str) + 0 == 0);  // a4a  return, two levels of operation
  endfunction

  function int a5 (string expr, string str);
    string s; s = expr;
    return dpi_ctx_i(s, str);             // a5a  return, BARE call (no operation)
  endfunction

  // ---- a6: return-with-comparison, NON-DPI callee, identical otherwise
  function bit a6 (string expr, string str);
    string s; s = expr;
    return (sv_i(s, str) == 0);           // a6a
  endfunction

  // ---- a7: return-with-comparison, DPI PLAIN (no context) callee
  function bit a7 (string expr, int k);
    string s; s = expr;
    return (dpi_pln_i(s, k) == 0);        // a7a
  endfunction

  // ---- a8: argument KINDS into the head shape
  function bit a8 (string expr, string str, int k);
    string s; string q[$]; st_t sv; logic [7:0] v; cls c;
    s = expr; v = 8'h0; c = new();
    return (dpi_ctx_i("lit", str) == 0)   // a8a  string literal arg
        || (dpi_ctx_i({s, "x"}, str) == 0) // a8b  concat expression arg
        || (dpi_ctx_i(q[0], str) == 0)     // a8c  queue element arg
        || (dpi_ctx_i(c.cs, str) == 0)     // a8d  class member arg
        || (dpi_pln_i(s, k + 1) == 0)      // a8e  int expression arg
        || (dpi_pln_i(s, sv.a) == 0)       // a8f  struct member arg
        || (dpi_pln_i(s, v) == 0);         // a8g  logic vector into int formal
  endfunction

  // ---- a9: void DPI task-like call as a STATEMENT
  function void a9 (string expr);
    dpi_pln_v(expr);                      // a9a
  endfunction

  task a9t (string expr);
    sv_t(expr);                           // a9b  SV task call statement
    dpi_pln_v(expr);                      // a9c  DPI void call in a task
  endtask

  // ---- a10: method calls and system calls in the head shape
  function bit a10 (string expr, int k);
    cls c; c = new();
    return (c.m_i(expr, k) == 0)          // a10a method_func_call
        || ($sformatf("%s", expr) == "")  // a10b sys_func_call
        || (sv_ii(k, k) == 0);            // a10c SV int function
  endfunction

  // ---- a11: the head shape but the ENCLOSING function returns int / void
  function int a11 (string expr, string str);
    string s; s = expr;
    return (dpi_ctx_i(s, str) == 0);      // a11a enclosing returns int
  endfunction

  function void a12 (string expr, string str);
    string s; bit b; s = expr;
    b = (dpi_ctx_i(s, str) == 0);         // a12a enclosing returns void
  endfunction

endpackage

module top8;
  import p8::*;
  bit r;
  initial begin
    r = a1("a", "b");
  end
endmodule
