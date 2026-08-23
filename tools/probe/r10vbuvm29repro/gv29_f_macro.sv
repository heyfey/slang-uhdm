// r10vbuvm29 arm F (VERIFIER) — the head's REAL provenance: the cast text
// comes from a MACRO body (`uvm_packer_defines.svh:211`).  Macro expansion is
// exactly where slang's `expr.syntax` attribution can differ from a
// hand-written cast, and § castOverStreamKeepsCast29 keys on that syntax.
// Also: a PARAMETERIZED class (the head's class is parameterized in UVM), an
// OOB method, and THREE instances of the carrying module.
`define UNPACK_ENUM(VAR, TYPE) \
    VAR = TYPE'({ << bit { __array }});

package vf29;
  typedef enum { R0e, R1e } cmd_e;
  class gp #(type T = cmd_e);
    T m_command;
    bit __array[];
    extern function void do_unpack();
    function void inline_unpack();
      `UNPACK_ENUM(m_command, cmd_e)
    endfunction
  endclass
  function void gp::do_unpack();
    `UNPACK_ENUM(m_command, T)
  endfunction
endpackage

module vf29m;
  import vf29::*;
  gp #(cmd_e) h;
  initial begin
    h = new();
    h.do_unpack();
    h.inline_unpack();
  end
endmodule

module vf29top;
  vf29m a();
  vf29m b();
  vf29m c();
endmodule
