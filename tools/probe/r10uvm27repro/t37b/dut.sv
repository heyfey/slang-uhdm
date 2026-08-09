// r10uvm27 t37b — the constructor-body matrix.  Surelog's
// CompileHelper::compileClassConstructorDeclaration (CompileStmt.cpp:2165)
// reads `Tf_port_list = fC->Child(nodeId)` and only then decides where the
// statement list starts, so the presence/absence of a PORT LIST and of
// `super.new` are the two axes.  Each class below is one cell; the name says
// [port list?][super.new?][how many trailing statements].
package pk;

  class base;
    int b;
    function new(int x = 1);
      b = x;
    endfunction
  endclass

  // no port list, no super, 1 stmt
  class c_np_ns_1 extends base;
    int a;
    function new();
      a = 1;
    endfunction
  endclass

  // no port list, no super, 3 stmts
  class c_np_ns_3 extends base;
    int a, c, d;
    function new();
      a = 1;
      c = 2;
      d = 3;
    endfunction
  endclass

  // no port list, super, 0 trailing stmts
  class c_np_s_0 extends base;
    function new();
      super.new();
    endfunction
  endclass

  // no port list, super, 1 trailing stmt
  class c_np_s_1 extends base;
    int a;
    function new();
      super.new();
      a = 1;
    endfunction
  endclass

  // no port list, super, 3 trailing stmts  (the UVM uvm_tree_printer shape,
  // which golden renders as a begin holding ONLY the 3 assignments)
  class c_np_s_3 extends base;
    int a, c, d;
    function new();
      super.new();
      a = 1;
      c = 2;
      d = 3;
    endfunction
  endclass

  // port list, super, 3 trailing stmts
  class c_p_s_3 extends base;
    int a, c, d;
    function new(int k);
      super.new(k);
      a = 1;
      c = 2;
      d = 3;
    endfunction
  endclass

  // port list, no super, 3 stmts
  class c_p_ns_3 extends base;
    int a, c, d;
    function new(int k);
      a = k;
      c = 2;
      d = 3;
    endfunction
  endclass

  // no port list, super with args, 3 trailing stmts
  class c_np_sa_3 extends base;
    int a, c, d;
    function new();
      super.new(5);
      a = 1;
      c = 2;
      d = 3;
    endfunction
  endclass

  // block_item_declaration before super.new, no port list
  class c_np_bid_s_2 extends base;
    int a, c;
    function new();
      int t;
      super.new();
      a = 1;
      c = 2;
    endfunction
  endclass

  // ---- out-of-body versions of the two interesting cells -----------------
  class o_np_s_3 extends base;
    int a, c, d;
    extern function new();
  endclass

  function o_np_s_3::new();
    super.new();
    a = 1;
    c = 2;
    d = 3;
  endfunction

  class o_np_ns_3 extends base;
    int a, c, d;
    extern function new();
  endclass

  function o_np_ns_3::new();
    a = 1;
    c = 2;
    d = 3;
  endfunction

  class o_p_s_3 extends base;
    int a, c, d;
    extern function new(int k);
  endclass

  function o_p_s_3::new(int k);
    super.new(k);
    a = 1;
    c = 2;
    d = 3;
  endfunction

endpackage

module top;
  pk::c_np_s_3 h;
  initial h = new();
endmodule
