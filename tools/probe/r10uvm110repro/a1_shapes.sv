// r10uvm110 arm a1 — DOTTED-LVALUE SHAPE GRID.
// Names/orders/case/lengths deliberately varied so no cell can agree by
// accident of a uniform naming scheme.
package Pk110A;

  class Payload110;
    byte unsigned m_byte_enable[];
    bit  BEQ[];
    int  Depth;
    string tag;
    Payload110 nxt;
  endclass

  class holderK;
    Payload110 h1;
    Payload110 arr[4];
    static Payload110 SHARED;
    int nbytes;
  endclass

  class Runner110;
    Payload110 gp;        // local-ish: class property named like the head's local
    holderK    KH;
    int        n7;

    // ---- c01..c12: BLOCKING, receiver = a LOCAL handle, varying Rhs kind
    function void body_local();
      Payload110 gp;          // c-local handle, shadows the property
      int nbytes;
      holderK    kk;
      gp     = new();
      nbytes = 9;
      gp.m_byte_enable = new [nbytes];              // c01 dyn-array new, size=ref
      gp.BEQ           = new [4];                   // c02 dyn-array new, size=lit
      gp.m_byte_enable = new [nbytes] (gp.m_byte_enable); // c03 dyn-array new+copy
      gp.nxt           = new ();                    // c04 class new, parens
      gp.Depth         = 33;                        // c05 plain literal
      gp.Depth         = nbytes + 1;                // c06 expression
      gp.tag           = $sformatf("%0d", nbytes);  // c07 system call
      gp.Depth         = fret110(nbytes);           // c08 user func call
      gp.Depth        += 2;                         // c09 compound
      gp.nxt.Depth     = 7;                         // c10 two-dot plain
      gp.nxt.m_byte_enable = new [3];               // c11 two-dot dyn-array new
      kk = new();
      kk.arr[2].m_byte_enable = new [5];            // c12 indexed receiver + new[]
    endfunction

    function int fret110(int q); return q; endfunction

    // ---- c13..c20: other receiver DECLARATIONS
    function void body_formal(Payload110 fp, ref Payload110 rp);
      fp.m_byte_enable = new [2];                   // c13 formal (input) recv
      rp.BEQ           = new [6];                   // c14 formal (ref) recv
      fp.Depth         = 1;                         // c15 formal, plain rhs
    endfunction

    function void body_prop();
      gp.m_byte_enable = new [n7];                  // c16 class-PROPERTY recv
      KH.h1.BEQ        = new [8];                   // c17 prop.prop recv
      holderK::SHARED.m_byte_enable = new [1];      // c18 STATIC-qualified recv
      KH.arr[1].BEQ    = new [2];                   // c19 prop indexed recv
      this.gp.Depth    = 5;                         // c20 this. plain rhs
    endfunction

    // ---- c21..c24: this. receivers with new[]
    function void body_this();
      this.gp.m_byte_enable = new [n7];             // c21 this.recv + new[]
      this.gp.nxt           = new ();               // c22 this.recv + class new
      this.n7               = 4;                    // c23 this.<scalar>
      this.gp.nxt.BEQ       = new [3];              // c24 this.a.b + new[]
    endfunction

    // ---- c25..c28: TASK home, nonblocking / compound
    task body_task();
      Payload110 tp;
      tp = new();
      tp.m_byte_enable = new [2];                   // c25 task + new[]
      tp.Depth        <= 12;                        // c26 nonblocking dotted
      tp.Depth        += 3;                         // c27 compound dotted
      #1 tp.Depth      = 4;                         // c28 delayed dotted
    endtask

    extern function void body_oob();
  endclass

  // ---- c29..c32: OUT-OF-BODY method home
  function void Runner110::body_oob();
    Payload110 op;
    op = new();
    op.m_byte_enable = new [7];                     // c29 oob + new[]
    op.Depth         = 8;                           // c30 oob plain
    op.nxt           = new ();                      // c31 oob class new
    gp.BEQ           = new [9];                     // c32 oob, property recv
  endfunction
endpackage

module top110A;
  import Pk110A::*;
  Payload110 mp;
  int mw;
  initial begin
    mp = new();
    mw = 3;
    mp.m_byte_enable = new [mw];                    // c33 MODULE initial + new[]
    mp.Depth         = 2;                           // c34 module initial plain
    mp.nxt           = new ();                      // c35 module initial class new
  end
endmodule
