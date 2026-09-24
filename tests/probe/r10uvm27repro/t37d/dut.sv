// r10uvm27 t37d — the block_item_declaration cells of
// § constructorBodyElementShift27, where OUR emitter injects extra statements
// (a declaration with an initializer becomes a leading assignment) and where
// the dropped first element is a DECLARATION rather than a statement.
package pk;

  class base;
    int b;
    function new(int x = 1);
      b = x;
    endfunction
  endclass

  // first element is a decl WITH an initializer; it is the dropped one
  class e_initdecl_1 extends base;
    int a;
    function new();
      int t = 5;
      a = 1;
    endfunction
  endclass

  // two decls then one statement: nbStmts==2 -> a begin holding ONE assignment
  class e_2bid_1 extends base;
    int a;
    function new();
      int t;
      int u;
      a = 1;
    endfunction
  endclass

  // decl with initializer, no statements at all
  class e_initdecl_0 extends base;
    function new();
      int t = 5;
    endfunction
  endclass

  // super.new() then exactly two trailing statements
  class e_super_2 extends base;
    int a, c;
    function new();
      super.new();
      a = 1;
      c = 2;
    endfunction
  endclass

  // super.new() with a NON-empty argument list then two trailing statements
  class e_supera_2 extends base;
    int a, c;
    function new();
      super.new(9);
      a = 1;
      c = 2;
    endfunction
  endclass

  // a control: not a constructor, no port list, three statements
  class e_notctor extends base;
    int a, c, d;
    function void go;
      a = 1;
      c = 2;
      d = 3;
    endfunction
    task tgo;
      a = 4;
      c = 5;
      d = 6;
    endtask
  endclass

endpackage

module top;
  pk::e_super_2 h;
  initial h = new();
endmodule
