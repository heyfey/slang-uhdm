// r10uvm194 arm A — THE HOME GRID.  The same shape (a bare read and a bare
// write of the subroutine's own return name, plus a BIT-SELECT WRITE on that
// name as a DIRECT statement of the enclosing block) written in every HOME the
// corpus has.  The law's subject is the OUT-OF-BODY class method's PACKAGE
// listing; the free function is the positive control (it already agrees), the
// IN-BODY class method is the negative control (golden binds nothing there),
// and the MODULE function is the no-package control.
package a194_src;
  // (1) the package's OWN free function — already agreeing on both binaries.
  function string a_free();
    int i; i=0;
    a_free = {a_free," "};
    a_free[i] = 8'h41;
  endfunction

  // (2) a class method written INSIDE the class body: golden leaves every
  //     return-name reference BARE, in every view.
  class A194;
    function string a_in();
      int i; i=0;
      a_in = {a_in," "};
      a_in[i] = 8'h42;
    endfunction
    extern function string a_out();
    extern function string a_out_noselect();
    extern function string a_out_ifsel();
  endclass

  // (3) THE SUBJECT: a class method DEFINED OUT OF BODY at package scope.
  function string A194::a_out();
    int i; i=0;
    a_out = {a_out," "};
    a_out[i] = 8'h43;
  endfunction

  // (4) the same method WITHOUT a select: the return-name references must stay
  //     exactly as § classRetNameDefViewNoBind37 leaves them (bare in the
  //     package listing) — the arm that proves the exemption is the SELECT and
  //     not the out-of-body-ness.
  function string A194::a_out_noselect();
    int i; i=0;
    a_out_noselect = {a_out_noselect," "};
    i = i + 1;
  endfunction

  // (5) the same method with the select under an `if` — NOT a direct statement
  //     of the block, so Surelog's `uhdmbegin` arm never sees it.  This is the
  //     shape uvm-1.2's own `unpack_string` has, and it must stay bare.
  function string A194::a_out_ifsel();
    int i; i=0;
    a_out_ifsel = {a_out_ifsel," "};
    if (i == 0)
      a_out_ifsel[i] = 8'h44;
  endfunction
endpackage

// (6) a MODULE-scope function: no package home at all.
module a194_top;
  import a194_src::*;
  function string a_mod();
    int i; i=0;
    a_mod = {a_mod," "};
    a_mod[i] = 8'h45;
  endfunction
  string s1, s2, s3, s4, s5, s6;
  A194 h;
  initial begin
    h = new();
    s1 = a_free();
    s2 = h.a_in();
    s3 = h.a_out();
    s4 = h.a_out_noselect();
    s5 = h.a_out_ifsel();
    s6 = a_mod();
  end
endmodule
