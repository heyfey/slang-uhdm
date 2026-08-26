// r10uvm152 arm B — THE FIRST-BODY-ITEM TEST.  An out-of-body constructor with
// an EMPTY port list vs one with FORMALS, each with THREE body declarations and
// a leading non-declaration variant.  Golden decides which body items become
// subroutine locals and which exist only as package copies.
package pb152;

  class Kb152;
    int qb;
  endclass

  class E0b152;            // empty parens, decl FIRST
    int z0;
    extern function new();
  endclass

  class E1b152;            // no parens at all, decl FIRST
    int z1;
    extern function new;
  endclass

  class E2b152;            // empty parens, a STATEMENT first, then decls
    int z2;
    extern function new();
  endclass

  class F0b152;            // formals, decl FIRST
    int y0;
    extern function new(int a);
  endclass

  function E0b152::new();
    Kb152 e0_one;
    Kb152 e0_two;
    Kb152 e0_three;
    e0_one   = null;
    e0_two   = null;
    e0_three = null;
    z0 = 1;
  endfunction

  function E1b152::new;
    Kb152 e1_one;
    Kb152 e1_two;
    e1_one = null;
    e1_two = null;
    z1 = 2;
  endfunction

  function E2b152::new();
    z2 = 3;
    begin
      Kb152 e2_one;
      Kb152 e2_two;
      e2_one = null;
      e2_two = null;
    end
  endfunction

  function F0b152::new(int a);
    Kb152 f0_one;
    Kb152 f0_two;
    f0_one = null;
    f0_two = null;
    y0 = a;
  endfunction

endpackage

module mb152;
  import pb152::*;
  initial begin
    E0b152 e0; E1b152 e1; E2b152 e2; F0b152 f0;
    e0 = new(); e1 = new(); e2 = new(); f0 = new(7);
  end
endmodule
