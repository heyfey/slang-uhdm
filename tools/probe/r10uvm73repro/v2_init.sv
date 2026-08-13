// r10uvm73 VERIFIER arm v2 — THE INITIALIZER ARMS THE PATCH DID **NOT** GATE.
//
// emitClassDefn's property-initializer decode has SEVEN arms:
//   NamedValue | IntegerLiteral | UnaryOp(Minus) | StringLiteral | RealLiteral
//   | TimeLiteral | NullLiteral
// The patch gates exactly THREE of them (IntegerLiteral, the negated-integer
// operand, NullLiteral).  If r10buvm2's law is really "NO TYPESPEC -> the
// constant is class_defn-parented (and, per this pass, sized 64)", then the
// FOUR ungated arms are EMPTY PRODUCT CELLS: a degraded property initialised
// with a STRING, a REAL, a TIME literal or a NAMED VALUE would keep our
// var-parent where golden re-parents it.  The shipped grid initialises only
// `= null`, `= 7`, `= 3` and `= -1`, so it could not have seen this.
//
// Every degraded cell (c_*) is paired with the identical initializer on an
// OWN-class typedef control (k_*), so a parent/size difference that is really
// pre-existing (residue R5's family) is separated from one this law owns.
package p1;
  parameter int P_SEVEN = 7;

  class holder;
    typedef enum {H_A, H_B} e_t;
    typedef string  s_t;
    typedef real    r_t;
    typedef time    t_t;
    typedef int     i_t;
    typedef bit [95:0] w_t;      // WIDER than 64 -> does the "size 64" hold?
    typedef bit [3:0]  n_t;      // NARROWER than 64
  endclass

  class initee;
    holder::s_t c_strinit  = "hi";      // STRING literal   -- ungated arm
    holder::r_t c_realinit = 1.5;       // REAL   literal   -- ungated arm
    holder::t_t c_timeinit = 5ns;       // TIME   literal   -- ungated arm
    holder::i_t c_namedinit = P_SEVEN;  // NAMED  value     -- ungated arm
    holder::r_t c_negreal  = -1.5;      // NEGATED REAL     -- ungated arm
    holder::w_t c_wideinit = 96'd7;     // 96-bit prop, int literal (gated arm)
    holder::n_t c_narrinit = 4'd7;      //  4-bit prop, int literal (gated arm)
  endclass

  // CONTROLS: identical initializers over the class's OWN typedefs
  class ctl;
    typedef string  s_t;
    typedef real    r_t;
    typedef time    t_t;
    typedef int     i_t;
    typedef bit [95:0] w_t;
    typedef bit [3:0]  n_t;
    s_t k_strinit  = "hi";
    r_t k_realinit = 1.5;
    t_t k_timeinit = 5ns;
    i_t k_namedinit = P_SEVEN;
    r_t k_negreal  = -1.5;
    w_t k_wideinit = 96'd7;
    n_t k_narrinit = 4'd7;
  endclass
endpackage

module top;
  p1::initee i; p1::ctl k;
  initial begin i = new(); k = new(); end
endmodule
