// r10uvm167 grid, arm B — THE SPELLINGS, and THE AWAY COLUMN.
//
// Golden does NOT always list only the written arguments.  § namedTfArgsFormalSlots4
// (r10uvm4) measured the other face: a RECEIVER-LESS `func_call` / `task_call`
// written with NAMED association gets ONE vpiArgument PER FORMAL, in FORMAL
// order, with a LOC-LESS `INT:0` placeholder for every formal the call site did
// not write.  A filter that trims a call of THAT face would be AWAY, so this
// arm puts every receiver-less spelling INSIDE the shell as well as outside it.
//
// Every `sh*` subroutine here carries the same `T167::` shell trigger arm A
// decodes; every `cl*` one is its bindable twin.
package bp167;

  function automatic int pf167(int a, int b = 3, int c = 5);
    return a + b + c;
  endfunction

  task automatic pt167(int a, int b = 3);
  endtask

  class Rcv167;
    function int mf167(int a, int b = 3, int c = 5);
      return a + b + c;
    endfunction
    task mt167(int a, int b = 3);
    endtask
  endclass

  class Gsh167 #(type T167 = int);

    // an IN-CLASS bare (receiver-less) method call: golden emits a func_call
    // for this, so it takes the TF-CALL rule, not the method rule (r10uvm4 a2 E1)
    function int im167(int a, int b = 3, int c = 5);
      return a + b + c;
    endfunction
    task it167(int a, int b = 3);
    endtask

    static function int sh_pkg_pos();
      // PACKAGE function, POSITIONAL, two formals defaulted away
      return pf167(T167::type_name);
    endfunction

    static function int sh_pkg_named();
      // PACKAGE function, NAMED, a MIDDLE formal skipped
      return pf167(.a(T167::type_name), .c(9));
    endfunction

    static task sh_pkg_task();
      // PACKAGE task, POSITIONAL, one formal defaulted away
      pt167(T167::type_name);
    endtask

    function int sh_in_pos();
      // IN-CLASS BARE call, POSITIONAL
      return im167(T167::type_name);
    endfunction

    function int sh_in_named();
      // IN-CLASS BARE call, NAMED, reordered and a formal skipped
      return im167(.c(T167::type_name), .a(1));
    endfunction

    task sh_in_task();
      // IN-CLASS BARE task, POSITIONAL
      it167(T167::type_name);
    endtask

    function int sh_meth_named(Rcv167 r);
      // METHOD, NAMED, a middle formal skipped  (the method rule: written only)
      return r.mf167(.a(T167::type_name), .c(9));
    endfunction

    function int sh_meth_mixed(Rcv167 r);
      // METHOD, MIXED positional + named
      return r.mf167(T167::type_name, .c(9));
    endfunction

    task sh_meth_task(Rcv167 r);
      // METHOD TASK, POSITIONAL
      r.mt167(T167::type_name);
    endtask

    function int sh_trailing_empty();
      // a TRAILING EMPTY SLOT: `f(a,b,)` — Surelog's own INT:0, not a default
      return pf167(T167::type_name, 2, );
    endfunction
  endclass

  class Gcl167 #(type T167 = int);
    function int im167(int a, int b = 3, int c = 5);
      return a + b + c;
    endfunction
    task it167(int a, int b = 3);
    endtask

    static function int cl_pkg_pos();
      return pf167(1);
    endfunction
    static function int cl_pkg_named();
      return pf167(.a(1), .c(9));
    endfunction
    static task cl_pkg_task();
      pt167(1);
    endtask
    function int cl_in_pos();
      return im167(1);
    endfunction
    function int cl_in_named();
      return im167(.c(2), .a(1));
    endfunction
    task cl_in_task();
      it167(1);
    endtask
    function int cl_meth_named(Rcv167 r);
      return r.mf167(.a(1), .c(9));
    endfunction
    function int cl_meth_mixed(Rcv167 r);
      return r.mf167(1, .c(9));
    endfunction
    task cl_meth_task(Rcv167 r);
      r.mt167(1);
    endtask
    function int cl_trailing_empty();
      return pf167(1, 2, );
    endfunction
  endclass

endpackage
