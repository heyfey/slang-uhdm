// r10sd11 grid cell g5 — THE UVM SHAPE, transcribed.
//
// `typedef uvm_queue#(uvm_resource_base) rsrc_q_t;` is a typedef whose written
// target is a PARAMETERISED class name, read from a class whose NAME sorts
// BEFORE its owner.  This cell reproduces that exactly (`zres5::q_t` =
// `aq5#(abase5)`) and puts the ordinary un-parameterised control beside it, so
// a predicate that only accepts a plain `IdentifierName` target is caught here.
// NOTE the difference from UVM: `aq5` has NO typedef of itself, so `q_t` is the
// only claimant of `aq5` and must RESOLVE.  `g7` `p_a`/`p_b` is the cell that
// makes the generic a SHARED slot, and UVM's `uvm_queue#(T)::this_type` is the
// claimant that pushes `rsrc_q_t` out.
package px5;
  // ORDERING NOTE.  slang refuses `Owner::td` when `Owner` is only
  // forward-declared, so every owner class is written BEFORE its user and the
  // USER class is written LAST.  That costs the cell nothing: Surelog's class
  // pass is LEXICOGRAPHIC (r10sd10 `g8`), and this law's claim order is read
  // off NAMES too, so `auser*` still sorts first and every `z*` owner still
  // sorts after it.

  virtual class abase5;
    int q;
  endclass

  class aq5 #(type T = int);
    T x;
  endclass

  class zres5;
    typedef aq5#(abase5) q_t;
    typedef abase5       p_t;
    typedef int          i_t;
    typedef struct { time a; int unsigned b; } s_t;
  endclass

  class apool5;                          // sorts BEFORE zres5 -> owner LATE
    function void f5();
      zres5::q_t  a_parm;                // parameterised target  (UVM shape)
      zres5::p_t  a_plain;               // plain class-name target
      zres5::i_t  a_int;                 // int target            (control)
      zres5::s_t  a_struct;              // struct in place       (control)
    endfunction
    function zres5::q_t r5();
      zres5::q_t rv;
      return rv;
    endfunction
  endclass

endpackage

module top5;
  initial begin
    px5::apool5 u = new();
    u.f5();
  end
endmodule
