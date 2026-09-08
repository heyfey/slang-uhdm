// r10uvm216 ARM F — THE MUST-STAY CONTROL.  An interface with NO `export
// "DPI-C"` at all: DPI IMPORTS, plain functions, a task, a modport, an
// `extern` prototype and a class with methods.  Nothing here may move.  The
// LAST item is the positive control: ONE export, so the arm proves the gate
// can see a move at all.
interface f216_if();
   import "DPI-C" context function void f216_imp_ctx(input int x);
   import "DPI-C" function int f216_imp_plain();
   import "DPI-C" pure function int f216_imp_pure(input int x);

   int f216_state;

   function void f216_plain1(int p);
      f216_state = p;
   endfunction

   function int f216_plain2(int p);
      return p + f216_imp_plain();
   endfunction

   task f216_plain3(int p);
      f216_state = p;
   endtask

   modport mp (import f216_plain1, import f216_plain2);

   class f216_cls;
      int m;
      function void set(int p);
         m = p;
      endfunction
      extern function int get();
   endclass

   function int f216_cls::get();
      return m;
   endfunction

   // THE POSITIVE CONTROL — one export, separated from its definition.
   export "DPI-C" function f216_positive;

   function void f216_other();
      f216_state = 1;
   endfunction

   function void f216_positive(input int a);
      f216_state = a;
   endfunction
endinterface

module f216_top();
   f216_if u_if();
endmodule
