// r10uvm27 t37c — the cells t37b left open for
// § constructorBodyElementShift27: block_item_declarations, a paren-LESS
// header, `super.new` written without parentheses, and an explicit
// begin..end body.  Each is a distinct value of "what is fC->Child(nodeId)".
package pk;

  class base;
    int b;
    function new(int x = 1);
      b = x;
    endfunction
  endclass

  // decl first, then ONE statement: predicted nbStmts==1 -> a BARE assignment
  class d_bid_1 extends base;
    int a;
    function new();
      int t;
      a = 1;
    endfunction
  endclass

  // decl only: predicted no stmt at all
  class d_bid_0 extends base;
    function new();
      int t;
    endfunction
  endclass

  // decl first, then TWO statements
  class d_bid_2 extends base;
    int a, c;
    function new();
      int t;
      a = 1;
      c = 2;
    endfunction
  endclass

  // NO parentheses on the header at all, 3 statements
  class d_noparen_3 extends base;
    int a, c, d;
    function new;
      a = 1;
      c = 2;
      d = 3;
    endfunction
  endclass

  // `super.new` written WITHOUT parentheses, then 1 statement
  class d_supernoparen_1 extends base;
    int a;
    function new();
      super.new;
      a = 1;
    endfunction
  endclass

  // `super.new` without parentheses, then 3 statements
  class d_supernoparen_3 extends base;
    int a, c, d;
    function new();
      super.new;
      a = 1;
      c = 2;
      d = 3;
    endfunction
  endclass

  // explicit begin..end body (ONE function_statement_or_null), no super
  class d_explicit extends base;
    int a, c;
    function new();
      begin
        a = 1;
        c = 2;
      end
    endfunction
  endclass

  // super.new() then an explicit begin..end
  class d_super_explicit extends base;
    int a, c;
    function new();
      super.new();
      begin
        a = 1;
        c = 2;
      end
    endfunction
  endclass

  // a defaulted single port -> a REAL tf_port_list, no shift
  class d_default_port extends base;
    int a, c;
    function new(int k = 0);
      super.new(k);
      a = 1;
      c = 2;
    endfunction
  endclass

endpackage

module top;
  pk::d_bid_2 h;
  initial h = new();
endmodule
