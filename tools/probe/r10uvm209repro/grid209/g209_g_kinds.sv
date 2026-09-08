// r10uvm209 grid arm G — THE REMAINING KINDS, hoisted.  § 26's rule has a
// FALLBACK for a declaration with no `DataDeclaration` syntax parent
// (`enum_var || class_var` -> net shape), and an ENUM typedef is the one kind
// that reaches it.  This arm puts a typedef'd enum, a packed-vector typedef, a
// `real`, a `bit`, a `chandle` and a queue in an out-of-body constructor body
// beside their package-scope twins, so the cross is kind-complete.
//
// The package-scope twin of the packed-vector typedef is deliberately ABSENT:
// such a declaration is a NET at package scope (§ 5's written-type split), so
// including it shifts every later listing position and buries the qualifier
// cells this arm exists to read.  The hoisted `vg209_t lg_vec` is present —
// inside a subroutine body there is no net_declaration alternative.
//
// It also carries the note that arm G could NOT be written for: neither
// `function static <cls>::new()` nor `function automatic <cls>::new()` is
// accepted (slang: "class methods cannot have static lifetime"; Surelog:
// syntax error on both).  A hoisted constructor local therefore has no
// enclosing lifetime keyword to inherit, which is why carrying the SOURCE
// VARIABLE's lifetime and reading the DECLARATION's own qualifier are the same
// rule here — the one place the two could differ is unwritable.
package pg209;
  typedef enum { GA209, GB209 } eg209_t;
  typedef logic [3:0] vg209_t;
  class cm209;
    int n;
  endclass
  eg209_t  pg_enum;
  real     pg_real;
  bit      pg_bit;
  chandle  pg_ch;
  int      pg_q[$];
  class cn209;
    int q;
    extern function new();
  endclass
  function cn209::new();
    eg209_t  lg_enum;
    vg209_t  lg_vec;
    real     lg_real;
    bit      lg_bit;
    chandle  lg_ch;
    int      lg_q[$];
    lg_enum = GA209;
    lg_real = 0.0;
    q = 5;
  endfunction
endpackage

import pg209::*;

module gg209;
  initial $display("g");
endmodule
