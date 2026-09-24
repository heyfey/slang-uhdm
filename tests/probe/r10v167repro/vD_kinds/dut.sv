// r10v167 arm D - CALL KINDS: constructor with defaults, super.new, a virtual
// method through a BASE handle, a hierarchical call, DPI import with defaults,
// system tf calls (the NO-DEFAULT control), a paren-less task call, and the
// same callee called fully-written and defaulted in ONE method.
package pd167;
  import "DPI-C" function int dpi167(input int a, input int b);

  class base167;
    int r;
    function new(int a = 1, int b = 2);
      r = a + b;
    endfunction
    virtual function int vf167(int a, int b = 31, int c = 32);
      return a + b + c;
    endfunction
    task nopar167();
      r = 1;
    endtask
  endclass

  class kid167 extends base167;
    function new(int a = 4);
      super.new(a);
    endfunction
    virtual function int vf167(int a, int b = 31, int c = 32);
      return a - b - c;
    endfunction
  endclass

  function int df167(int a, int b = 41, int c = 42);
    return a + b + c;
  endfunction

  class shD167 #(type T167 = int);
    base167 bh;
    kid167  kh;
    int r;
    string s;
    task goD();
      // constructor with defaults - clean and shelled
      bh = new(1);
      bh = new(T167::nm167);
      kh = new(T167::nm167);
      // virtual method through a BASE handle
      r = bh.vf167(1);
      r = bh.vf167(T167::nm167);
      r = bh.vf167(.a(T167::nm167), .c(9));
      // paren-less task call
      bh.nopar167;
      // DPI import
      r = dpi167(1, 2);
      r = dpi167(T167::nm167, 2);
      // system tf - the no-default control
      s = $sformatf("%0d", 3);
      s = $sformatf("%0d", T167::nm167);
      $display("x %0d", T167::nm167);
      // the SAME callee, fully written and defaulted, in ONE method
      r = df167(1, 41, 42);
      r = df167(1);
      r = df167(T167::nm167, 41, 42);
      r = df167(T167::nm167);
    endtask
  endclass
endpackage
