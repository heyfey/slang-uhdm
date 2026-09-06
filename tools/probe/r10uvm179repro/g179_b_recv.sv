// r10uvm179 arm B — THE RECEIVER SHAPES, all read off ONE golden.
// MEASUREMENT ONLY.  Every cell stands in the FACE position (an `if`
// CONDITION, i.e. EXPRESSION position) with the SAME argument — a `ref_var`
// local of the class type parameter — so the ONLY thing that varies is the
// RECEIVER's shape.  This is the axis uvm176 could not read (its law lived on
// the STATEMENT road) and the axis this pass's window has to be exact about.
//
// Shapes: a class PROPERTY, a body LOCAL handle, the method's FORMAL, an
// `a.b` CHAIN, an INDEXED receiver, a `this.`-rooted one, a VIRTUAL INTERFACE
// (uvm176's own face, which must not move) and NO receiver at all.
package pb179;

  interface class ig179;
  endclass

  class d179b;
    int fld;
  endclass

  class sink179b;
    d179b   inner;
    function void take(d179b v); endfunction
    function int  ask(d179b v); return 0; endfunction
  endclass

  class mid179b;
    sink179b leaf;
  endclass

  class c179b #(type T = d179b);
    sink179b s;              // one class PROPERTY
    mid179b  mid;            // an a.b CHAIN root
    sink179b bank[4];        // an INDEXED receiver
    int      w;

    extern function void r_prop();      // s.ask(v)          — THE CORPUS SHAPE
    extern function void r_local();     // a body LOCAL handle
    extern function void r_formal();    // the method's FORMAL
    extern function void r_chain();     // mid.leaf.ask(v)
    extern function void r_index();     // bank[1].ask(v)
    extern function void r_this();      // this.s.ask(v)
    extern function void r_none();      // no receiver at all
    extern function void r_prop_stmt(); // the STATEMENT twin of r_prop
    extern function void r_chain_stmt();// the STATEMENT twin of r_chain
    extern function void r_index_stmt();// the STATEMENT twin of r_index
  endclass

  function void c179b::r_prop();
    T v;
    if (s.ask(v) == 0) w = 1;                 // b01 one PROPERTY receiver
  endfunction

  function void c179b::r_local();
    T v;
    sink179b loc;
    if (loc.ask(v) == 0) w = 1;               // b02 a body LOCAL handle
  endfunction

  function void c179b::r_formal();
    T v;
    if (held179b(v) == 0) w = 1;              // b03 (helper below takes the formal)
  endfunction

  function void c179b::r_chain();
    T v;
    if (mid.leaf.ask(v) == 0) w = 1;          // b04 an a.b CHAIN
  endfunction

  function void c179b::r_index();
    T v;
    if (bank[1].ask(v) == 0) w = 1;           // b05 an INDEXED receiver
  endfunction

  function void c179b::r_this();
    T v;
    if (this.s.ask(v) == 0) w = 1;            // b06 a this.-rooted receiver
  endfunction

  function void c179b::r_none();
    T v;
    if (free179b(v) == 0) w = 1;              // b07 NO receiver
  endfunction

  function void c179b::r_prop_stmt();
    T v;
    s.take(v);                                // b11 the STATEMENT twin of b01
  endfunction

  function void c179b::r_chain_stmt();
    T v;
    mid.leaf.take(v);                         // b14 the STATEMENT twin of b04
  endfunction

  function void c179b::r_index_stmt();
    T v;
    bank[1].take(v);                          // b15 the STATEMENT twin of b05
  endfunction

  function int free179b(d179b v); return 0; endfunction
  function int held179b(d179b v); return 0; endfunction

endpackage

// The VIRTUAL-INTERFACE receiver — r10uvm176's own face.  Its argument here is
// a FORMAL (an `io_decl`, not a `ref_var`), which is what makes it the control
// this pass must not disturb.
interface vif179b;
  function void poke(int k); endfunction
  function int  peek(int k); return 0; endfunction
endinterface

package pv179;
  class cv179;
    virtual vif179b vif;
    int w;
    extern function void v_stmt(int a);   // uvm176's face: STATEMENT, formal arg
    extern function void v_cond(int a);   // the EXPRESSION twin
  endclass
  function void cv179::v_stmt(int a);
    vif.poke(a);                              // b20 vif receiver, STATEMENT
  endfunction
  function void cv179::v_cond(int a);
    if (vif.peek(a) == 0) w = 1;              // b21 vif receiver, EXPRESSION
  endfunction
endpackage

module top179b;
  import pb179::*;
  import pv179::*;
  vif179b theif();
  c179b #(d179b) instb;
  cv179          instv;
  initial begin
    instb = new();
    instv = new();
  end
endmodule
