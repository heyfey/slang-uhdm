// r10uvm27 t37a — does golden emit `super.new()` / `super.f()` as a statement,
// and does the answer depend on IN-BODY vs OUT-OF-BODY definition?
// The UVM head is uvm_printer.svh:1130 `function uvm_tree_printer::new();
// super.new(); ...` — an OUT-OF-BODY constructor whose super.new() golden DROPS
// while we emit a method_func_call.  Both directions + both arities.
package pk;

  class base;
    int b;
    function new(int x = 1);
      b = x;
    endfunction
    function void bump();
      b = b + 1;
    endfunction
    function void bump2(int k);
      b = b + k;
    endfunction
  endclass

  // ---- arm A: everything IN BODY ----------------------------------------
  class inbody extends base;
    int a;
    function new();
      super.new();      // A1: super.new, no args, in body
      a = 0;
    endfunction
    function void m1();
      super.bump();     // A2: super.<method>, no args, in body
      a = 1;
    endfunction
    function void m2();
      super.bump2(3);   // A3: super.<method>, args, in body
      a = 2;
    endfunction
    function void m3();
      this.bump();      // A4: this.<method>, control for the handle kind
      a = 3;
    endfunction
  endclass

  // ---- arm B: everything OUT OF BODY (extern prototypes) -----------------
  class outbody extends base;
    int a;
    extern function new();
    extern function void m1();
    extern function void m2();
    extern function void m3();
  endclass

  function outbody::new();
    super.new();        // B1: the UVM shape exactly
    a = 0;
  endfunction

  function void outbody::m1();
    super.bump();       // B2
    a = 1;
  endfunction

  function void outbody::m2();
    super.bump2(3);     // B3
    a = 2;
  endfunction

  function void outbody::m3();
    this.bump();        // B4
    a = 3;
  endfunction

  // ---- arm C: super.new WITH arguments, both placements -----------------
  class inbodyarg extends base;
    function new();
      super.new(7);     // C1
    endfunction
  endclass

  class outbodyarg extends base;
    extern function new();
  endclass

  function outbodyarg::new();
    super.new(7);       // C2
  endfunction

endpackage

module top;
  pk::inbody i1;
  pk::outbody o1;
  initial begin
    i1 = new();
    o1 = new();
  end
endmodule
