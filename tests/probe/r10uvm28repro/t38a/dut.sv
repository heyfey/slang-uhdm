// r10uvm28 t38a — the reference-BINDING matrix (`vpiActual` on a ref_obj).
//
// r10uvm28g measures 1850 references in the UVM-4 whose `Actual_group` differs
// from golden's, and its 2x2 says the single largest cell is CONSTRUCTOR
// io_decl references: golden binds 399 of them and we bind none.  The rest is
// a long tail in ordinary methods, in both directions.  This file puts the
// SAME body in a constructor and in an ordinary method so the two can be
// diffed cell for cell, with every reference class (formal / bare local /
// initialised local / class property) in every syntactic position.
package pk;

  class base;
    int b;
    function new(int x = 0, string s = "");
      b = x;
    endfunction
  endclass

  // ---- arm 1: the body lives in a CONSTRUCTOR ---------------------------
  class c_ctor extends base;
    int p;
    string ps;
    function new(int a, string s);
      int lb;
      int li = 7;
      super.new(a, s);
      lb = a;
      p = li;
      ps = s;
      mm(a);
      mm(lb);
      mm(li);
      mm(p);
      if (a == 0) p = 1;
      if (lb == 0) p = 2;
      if (li == 0) p = 3;
      if (p == 0) p = 4;
      p = a + lb + li;
      $display("%0d", a);
    endfunction
    function void mm(int z);
    endfunction
  endclass

  // ---- arm 2: the SAME body in an ordinary METHOD ------------------------
  class c_meth extends base;
    int p;
    string ps;
    function void go(int a, string s);
      int lb;
      int li = 7;
      lb = a;
      p = li;
      ps = s;
      mm(a);
      mm(lb);
      mm(li);
      mm(p);
      if (a == 0) p = 1;
      if (lb == 0) p = 2;
      if (li == 0) p = 3;
      if (p == 0) p = 4;
      p = a + lb + li;
      $display("%0d", a);
    endfunction
    function void mm(int z);
    endfunction
  endclass

  // ---- arm 3: a CONSTRUCTOR with NO super.new call -----------------------
  class c_nosuper extends base;
    int p;
    function new(int a);
      int lb;
      lb = a;
      p = lb;
      mm(a);
      if (a == 0) p = 1;
    endfunction
    function void mm(int z);
    endfunction
  endclass

  // ---- arm 4: a constructor whose super.new takes a NON-formal -----------
  class c_superlocal extends base;
    int p;
    function new(int a);
      int lb;
      super.new(3, "k");
      lb = a;
      p = lb;
    endfunction
  endclass

endpackage

module top;
  pk::c_ctor h;
  pk::c_meth g;
  pk::c_nosuper n;
  pk::c_superlocal q;
  initial begin
    h = new(1, "x");
    g = new();
    n = new(2);
    q = new(3);
  end
endmodule
