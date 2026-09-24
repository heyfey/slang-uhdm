// r10uvm27 t37e — the SECOND constructor law: a block_item_declaration inside
// a CONSTRUCTOR body becomes a statement (an Rhs-less `assignment` whose Lhs is
// the declared variable), while the same declaration inside an ordinary
// function/task is dropped from the statement list.  Surelog's
// compileClassConstructorDeclaration has no Rhs filter; compileFunction /
// compileTask do (CompileStmt.cpp ~2130).  Port-list arms only, so the
// element-shift law of t37b/t37c/t37d is out of the way.
package pk;

  class base;
    int b;
    function new(int x = 1);
      b = x;
    endfunction
  endclass

  // ctor WITH a port list, 2 plain decls, super.new, 1 statement
  class f_pl_2bid extends base;
    int a;
    function new(int k);
      int t;
      int u;
      super.new(k);
      a = 1;
    endfunction
  endclass

  // ctor WITH a port list, 1 decl WITH an initializer, 1 statement
  class f_pl_initbid extends base;
    int a;
    function new(int k);
      int t = 7;
      a = 1;
    endfunction
  endclass

  // ctor WITH a port list, an UNPACKED-array decl
  class f_pl_arrbid extends base;
    int a;
    function new(int k);
      int arr[3];
      a = 1;
    endfunction
  endclass

  // CONTROL: ordinary function, port list, 2 plain decls, 2 statements
  class f_ctrl extends base;
    int a, c;
    function void go(int k);
      int t;
      int u;
      a = 1;
      c = 2;
    endfunction
    task tg(int k);
      int t;
      a = 3;
      c = 4;
    endtask
  endclass

  // ctor with port list and a STRING decl (a non-integral local)
  class f_pl_strbid extends base;
    int a;
    function new(int k);
      string s;
      a = 1;
    endfunction
  endclass

endpackage

module top;
  pk::f_pl_2bid h;
  initial h = new(1);
endmodule
