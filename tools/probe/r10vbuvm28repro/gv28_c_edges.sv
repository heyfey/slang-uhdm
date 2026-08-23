// r10vbuvm28 arm C — EDGES where slang's EnumTypeSyntax::baseType read and
// Surelog's Base_typespec could DISAGREE, plus the must-not-move controls.
package pedge;
  typedef enum { A0, A1 } ba_t;                 // base-less
  typedef enum bit [0:0] { B0, B1 } bb_t;       // 1-bit base
  typedef enum logic signed [7:0] { S0 } bs_t;  // signed base
  typedef enum longint { L0 } bl_t;             // 64
  typedef enum integer { G0 } bg_t;             // integer
  typedef enum time { T0 } bt_t;                // time base (64)
  parameter int PWID = 5;
  typedef bit [PWID-1:0] wid_t;
  typedef enum wid_t { W0, W1 } bw_t;           // base is a TYPEDEF
  typedef enum { N0 = -3, N1 = 7 } bn_t;        // base-less, negative values
endpackage

class cparam #(type T = int, int N = 3);
  T   m_t;
  int m_n;
  function int f();
    return $bits(T) + $bits(m_t);
  endfunction
endclass

class cenumparam #(type E = pedge::ba_t);
  E m_e;
  function int f(); return $bits(E) + $bits(m_e); endfunction
endclass

module gv28_c_edges;
  import pedge::*;
  typedef enum { FA, FB } fwd_t;
  typedef fwd_t fwd_alias_t;
  // (Surelog rejects an alias-of-alias inside a module: CP0317)
  ba_t  a; bb_t b; bs_t s; bl_t l; bg_t g; bt_t t; bw_t w; bn_t n;
  fwd_alias_t fa2;
  enum { INL0, INL1 } inl;                      // INLINE anonymous, no typedef
  enum int { INT0, INT1 } inlint;               // inline WITH base
  // must-not-move controls
  bit [11:0] vec; int iv; byte bv; real rv; string sv; chandle chv;
  logic [3:0][7:0] pk2; int un [4]; int dyn []; int qq [$]; int aa [string];
  typedef struct packed { bit [3:0] x; bit [3:0] y; } nostruct_t;
  nostruct_t nst;
  cparam #(ba_t) cp1;   cparam #(int) cp2;
  cenumparam #(ba_t) ce1;
  parameter int PRM = 9;
  localparam int LPB = $bits(ba_t);
  localparam int LPV = $bits(vec);
  int r [40];
  initial begin
    r[0] = $bits(a); r[1] = $bits(b); r[2] = $bits(s); r[3] = $bits(l);
    r[4] = $bits(g); r[5] = $bits(t); r[6] = $bits(w); r[7] = $bits(n);
    r[8] = $bits(fa2); r[9] = $bits(inl); r[10] = $bits(inlint);
    r[11] = $bits(ba_t); r[12] = $bits(bb_t); r[13] = $bits(bw_t);
    r[14] = $bits(pedge::ba_t); r[15] = $bits(fwd_alias_t);
    // must NOT move
    r[16] = $bits(vec); r[17] = $bits(iv); r[18] = $bits(bv);
    r[19] = $bits(rv);  r[20] = $bits(sv); r[21] = 0; // chandle rejected by slang
    r[22] = $bits(pk2); r[23] = $bits(un); r[24] = $bits(dyn);
    r[25] = $bits(qq);  r[26] = $bits(aa); r[27] = $bits(nst);
    r[28] = $bits(nst.x); r[29] = $bits(pk2[1]); r[30] = $bits(vec[3:0]);
    r[31] = $bits(PRM); r[32] = $bits(int); r[33] = $bits(byte);
    // enum MEMBER (an enum_const, not the type)
    r[34] = $bits(A0); r[35] = $bits(B0);
    // expressions that golden KEEPS as a sys_func_call
    r[36] = $bits(~vec); r[37] = $bits(iv + 1); r[38] = $bits(a == A1 ? a : a);
    r[39] = $bits(cp2.m_t);
  end
endmodule
