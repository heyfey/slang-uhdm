// r10buvm3 arm 3 — the OVER-FIRE controls.  None of these positions is built
// with bypassTypedefShare set, so § aggMemberStructTdSharesListing3's `unban3`
// must be FALSE in every one of them and the emission must not move.
package r;
typedef struct {int a; string b;}                     us_t;
typedef struct packed {logic [3:0] a; logic [3:0] b;} ps_t;

// PACKAGE-scope aggregate typedef with struct-typedef members (the shape the
// head's own container has one level up) — the reference emission.
typedef struct {
  us_t p_us;
  ps_t p_ps;
  string p_s;
} pbox_t;
typedef union packed {
  ps_t pu_ps;
  logic [7:0] pu_lg;
} pubox_t;
pbox_t  pv;
pubox_t puv;

// a PARAMETERIZED class whose property is the package struct typedef
class pc #(int W = 8);
  us_t     m_us;
  ps_t     m_ps;
  logic [W-1:0] m_w;
  typedef struct {us_t g_us; logic [W-1:0] g_w;} gbox_t;
  gbox_t m_g;
endclass

// a class whose property is a struct typedef but which declares NO nested
// aggregate typedef at all (§ classScopedTypedefPropIsBareLogicVar73's shape)
class plain;
  us_t  m_direct;
  ps_t  m_pdirect;
  us_t  m_dq[$];
endclass
endpackage

// MODULE-scope aggregate typedef: not a class, no bypass, must not move.
module m3;
  typedef struct {r::us_t m_us; r::ps_t m_ps;} mbox_t;
  mbox_t mv;
  typedef struct packed {r::ps_t mp; logic [3:0] t;} mpbox_t;
  mpbox_t mpv;
endmodule
