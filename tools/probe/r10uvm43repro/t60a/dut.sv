// r10uvm43 arm t60a — THE KIND GATE OF § arrayElemTdClone42, MEASURED.
//
// Pass 42's verifier finding (b): the clone law's kind gate accepts only
// bit_typespec / logic_typespec bases, but golden SimpleUVM applies the SAME
// per-declaration-clone law to `typedef int uvm_action` (both int_typespec
// LISTING objects have fan-in 37 / 5, ALL of it from `int_typespec 'uvm_action'`
// clones and NONE from a container position).  The README justified the
// restriction with enum/struct/class only, so the integer-ATOM half of the gate
// was never measured.
//
// This arm carries ONE typedef per base kind through the two container
// positions the law covers (an unpacked array's ELEMENT typespec, an
// associative array's INDEX typespec) so the golden states the gate per KIND:
//
//   integer atoms  : int, byte, shortint, longint, integer, int unsigned, time
//   vectors        : bit[7:0] (the decoded case), logic (scalar), reg[3:0]
//   non-integral   : real, shortreal, string
//   the EXCLUSIONS : enum, packed struct, unpacked struct, union, class handle
//   chained        : a typedef OF a typedef (two hops)
//
// Read in the golden, per typedef: the LISTING object's `who` multiset.  A
// container position that shows up as `Nxarray_typespec` / `Nxconstant` on the
// LISTING line means golden binds the listing object DIRECTLY (no clone) and
// the kind must stay OUT of the gate; a listing line whose whole fan-in is
// `Nx<kind>_typespec'<bare alias>'` means golden clones and the kind belongs IN.
package pk60;

  typedef int          t_int;
  typedef byte         t_byte;
  typedef shortint     t_sint;
  typedef longint      t_lint;
  typedef integer      t_integer;
  typedef int unsigned t_uint;
  typedef time         t_time;

  typedef bit [7:0]    t_bit8;      // the decoded case (clones today)
  typedef logic        t_log1;      // scalar logic
  typedef reg [3:0]    t_reg4;

  typedef real         t_real;
  typedef shortreal    t_sreal;
  typedef string       t_str;

  typedef enum { E0, E1 }               t_enum;    // excluded today
  typedef struct packed { bit a; bit b; } t_pstr;   // excluded today
  typedef struct { int a; byte b; }       t_ustr;   // excluded today
  typedef union packed { bit [1:0] a; bit [1:0] b; } t_uni;

  typedef t_bit8       t_chain;      // a typedef OF a typedef

  class cls60;
    int x;
  endclass
  typedef cls60        t_cls;        // class-handle typedef

  // ---- ELEMENT position: a fixed unpacked array over each typedef --------
  t_int     e_int[4];
  t_byte    e_byte[4];
  t_sint    e_sint[4];
  t_lint    e_lint[4];
  t_integer e_integer[4];
  t_uint    e_uint[4];
  t_time    e_time[4];
  t_bit8    e_bit8[4];
  t_log1    e_log1[4];
  t_reg4    e_reg4[4];
  t_real    e_real[4];
  t_sreal   e_sreal[4];
  t_str     e_str[4];
  t_enum    e_enum[4];
  t_pstr    e_pstr[4];
  t_ustr    e_ustr[4];
  t_uni     e_uni[4];
  t_chain   e_chain[4];
  t_cls     e_cls[4];

  // ---- INDEX position: an associative array keyed by each typedef -------
  int i_int[t_int];
  int i_byte[t_byte];
  int i_sint[t_sint];
  int i_lint[t_lint];
  int i_integer[t_integer];
  int i_uint[t_uint];
  int i_time[t_time];
  int i_bit8[t_bit8];
  int i_log1[t_log1];
  int i_reg4[t_reg4];
  int i_str[t_str];
  int i_enum[t_enum];
  int i_pstr[t_pstr];
  int i_ustr[t_ustr];
  int i_chain[t_chain];

  // ---- plain scalar users, which must not move --------------------------
  t_int  s_int;
  t_bit8 s_bit8;
  t_enum s_enum;

  // ---- the same positions inside a CLASS (property) and a FUNCTION body -
  class holder60;
    t_int   cfix[4];
    t_bit8  cbit[4];
    int     cmapi[t_int];
    int     cmapb[t_bit8];
    extern function void body();
  endclass

  function void holder60::body();
    t_int  lfix[4];
    t_bit8 lbit[4];
    int    lmapi[t_int];
    int    lmapb[t_bit8];
    lfix[0]  = 1;
    lbit[0]  = 8'h1;
    lmapi[1] = 2;
    lmapb[8'h2] = 3;
  endfunction

endpackage

module dut60;
  import pk60::*;

  // MODULE-scope twins of the two interesting kinds
  typedef int       m_int;
  typedef bit [7:0] m_bit8;

  m_int  me_int[4];
  m_bit8 me_bit8[4];
  int    mi_int[m_int];
  int    mi_bit8[m_bit8];

  // the package typedefs used from a module (the ELABORATED listing's view)
  t_int  pe_int[4];
  t_bit8 pe_bit8[4];
  int    pi_int[t_int];

  initial begin
    me_int[0]  = 1;
    me_bit8[0] = 8'h2;
    mi_int[3]  = 4;
    pe_int[0]  = 5;
  end
endmodule
