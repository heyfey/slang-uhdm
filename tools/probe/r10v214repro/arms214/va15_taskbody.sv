// v214 arm 15 — TASKS, CONSTRUCTORS AND STATIC METHODS out of body, plus a
// method with a DEFAULT ARGUMENT that is the package's own parameter (the
// default expression lives in the io_decl, not the body).
package pv15;
  parameter int wa15 = 61;
  parameter wb15 = wa15;
  function automatic int wsink15(int a, int b); return a + b; endfunction
  class W15;
    int f;
    extern function new(int a = wb15);
    extern task w_tk15();
    extern static function int w_st15();
    extern function int w_def15(int a = wb15);
  endclass
  function W15::new(int a = wb15);
    f = a + wa15;
  endfunction
  task W15::w_tk15();
    f = wsink15(wa15, wb15);
  endtask
  function int W15::w_st15();
    return wa15 + wb15;
  endfunction
  function int W15::w_def15(int a = wb15);
    return a + wb15;
  endfunction
endpackage
module topv15;
  pv15::W15 w = new();
  int x;
  initial x = w.w_def15();
endmodule
