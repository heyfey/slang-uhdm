// r10uvm144 arm C — the POSITION / OWNER / ARGUMENT-KIND grid for a
// CLASS-SCOPE-QUALIFIED call (`Class::f(...)`) that keeps its func_call.
package p144c;

  class B144;
    extern static function int  gs(int x);
    extern static function void gv(int x);
    extern static function void gq(ref int a[$]);
    extern static task          gt(int x);
  endclass

  function int  B144::gs(int x); return x; endfunction
  function void B144::gv(int x); endfunction
  function void B144::gq(ref int a[$]); endfunction
  task          B144::gt(int x); endtask

  // ---------------- IN-BODY class methods ----------------
  class C144;
    int w;
    int p;

    // c01 STATEMENT position, subroutine local
    function void c01(); int loc; B144::gv(loc); w = 1; endfunction
    // c02 assignment RHS
    function void c02(); int loc; w = B144::gs(loc); endfunction
    // c03 IF condition
    function void c03(); int loc; if (B144::gs(loc) == 0) w = 3; endfunction
    // c04 WHILE condition
    function void c04(); int loc; while (B144::gs(loc) == 0) w = 4; endfunction
    // c05 RETURN operand
    function int c05(); int loc; return B144::gs(loc); endfunction
    // c06 operand of an operation
    function void c06(); int loc; w = B144::gs(loc) + 1; endfunction
    // c07 TASK call, statement position
    task c07(); int loc; B144::gt(loc); w = 7; endtask
    // c08 STATEMENT position, FORMAL argument
    function void c08(int f8); B144::gv(f8); w = 8; endfunction
    // c09 STATEMENT position, CLASS PROPERTY argument
    function void c09(); B144::gv(p); w = 9; endfunction
    // c10 STATEMENT position inside an IF BODY, local of the SUBROUTINE
    function void c10(); int loc; if (w == 1) begin B144::gv(loc); w = 10; end endfunction
    // c11 STATEMENT position inside an IF BODY, local of THAT block
    function void c11(); if (w == 1) begin int bl; B144::gv(bl); w = 11; end endfunction
    // c12 STATEMENT position inside a NAMED block
    function void c12(); if (w == 1) begin : nm12 int bl; B144::gv(bl); w = 12; end endfunction
    // c13 QUEUE local passed to a `ref ... [$]` formal, STATEMENT position
    function void c13(); int q13[$]; B144::gq(q13); w = 13; endfunction
    // c14 nested: the scoped call's argument is itself a scoped call's result
    function void c14(); int loc; B144::gv(B144::gs(loc)); w = 14; endfunction
    // c15 STATEMENT position inside a FOR body
    function void c15(); int loc; for (int i = 0; i < 2; i++) B144::gv(loc); endfunction
    // c16 two arguments, one literal
    function void c16(); int loc; B144::gv(loc + 0); w = 16; endfunction
    // c17 CONCATENATION operand
    function void c17(); bit [3:0] cl; B144::gv({cl, cl}); w = 17; endfunction
    // c18 SYSTEM call around it
    function void c18(); int loc; $display("%0d", B144::gs(loc)); endfunction
    // c19 STATEMENT position, unqualified BARE call control
    function void c19(); int loc; bare144(loc); w = 19; endfunction
    // c20 assignment RHS, unqualified BARE call control
    function void c20(); int loc; w = bare144s(loc); endfunction
  endclass

  function automatic void bare144(int x); endfunction
  function automatic int  bare144s(int x); return x; endfunction

  // ---------------- OUT-OF-BODY class methods ----------------
  class D144;
    int w;
    extern function void d01();
    extern function void d02();
    extern function void d03();
  endclass

  function void D144::d01(); int loc; B144::gv(loc); w = 1; endfunction
  function void D144::d02(); int loc; w = B144::gs(loc); endfunction
  function void D144::d03(); int q3[$]; B144::gq(q3); w = 3; endfunction

  // ---------------- PACKAGE FREE subroutines ----------------
  function automatic void e01(); int loc; B144::gv(loc); endfunction
  function automatic void e02(); int loc; int r; r = B144::gs(loc); endfunction
  function automatic void e03(); int q3[$]; B144::gq(q3); endfunction

endpackage

// ---------------- MODULE-owned class + module subroutine ----------------
module m144;
  class F144;
    int w;
    function void f01(); int loc; p144c::B144::gv(loc); w = 1; endfunction
  endclass
  function automatic void g01(); int loc; p144c::B144::gv(loc); endfunction
  initial g01();
endmodule
