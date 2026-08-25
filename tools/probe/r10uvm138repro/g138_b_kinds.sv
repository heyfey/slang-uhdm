// r10uvm138 arm B — ENUM-KIND grid: what Value does each enum declaration
// register, and therefore what fields does the folded return constant carry?
// One `return <ENUMERATOR>;` direct-statement function per kind.
package p138b;

  typedef enum { B0_A, B0_B, B0_C } eb0_t;              // no base type
  typedef enum int { B1_A, B1_B } eb1_t;                // int base
  typedef enum bit [3:0] { B2_A, B2_B } eb2_t;          // bit[4] base
  typedef enum logic [7:0] { B3_A, B3_B } eb3_t;        // logic[8] base
  typedef enum byte { B4_A, B4_B } eb4_t;               // byte base
  typedef enum { B5_A = 5, B5_B = 9 } eb5_t;            // explicit decimal
  typedef enum bit [3:0] { B6_A = 4'hA, B6_B = 4'hB } eb6_t;  // explicit based
  typedef enum int { B7_A = -3, B7_B = -1 } eb7_t;      // negative
  typedef enum { B8_A = 2, B8_B, B8_C } eb8_t;          // explicit then implicit
  typedef enum bit [1:0] { B9_A = 2'b10, B9_B = 2'b01 } eb9_t;
  typedef enum { BA_A = 1 << 2, BA_B } eba_t;           // computed value

  typedef enum bit [7:0] { BC_A = 8'o17, BC_B = 8'o20 } ebc_t;   // OCTAL
  typedef enum bit [7:0] { BD_A = 8'd7, BD_B = 8'd9 } ebd_t;     // SIZED DECIMAL
  typedef enum bit { BE_A = 1'b0, BE_B = 1'b1 } ebe_t;           // 1-bit
  typedef enum logic [3:0] { BF_A = 4'b0011, BF_B = 4'b0101 } ebf_t;
  typedef enum { BG_A = 'd5, BG_B = 'd6 } ebg_t;                 // UNSIZED based
  typedef enum int unsigned { BH_A, BH_B } ebh_t;                // int unsigned base
  typedef enum shortint { BI_A, BI_B } ebi_t;                    // shortint base
  typedef enum longint { BJ_A, BJ_B } ebj_t;                     // longint base

  enum { BB_A, BB_B } bb_var;                           // ANONYMOUS package enum

  function eb0_t f_b0(); return B0_B; endfunction
  function eb1_t f_b1(); return B1_B; endfunction
  function eb2_t f_b2(); return B2_B; endfunction
  function eb3_t f_b3(); return B3_B; endfunction
  function eb4_t f_b4(); return B4_B; endfunction
  function eb5_t f_b5(); return B5_B; endfunction
  function eb6_t f_b6(); return B6_B; endfunction
  function eb7_t f_b7(); return B7_A; endfunction
  function eb7_t f_b7b(); return B7_B; endfunction
  function eb8_t f_b8(); return B8_B; endfunction
  function eb9_t f_b9(); return B9_A; endfunction
  function eba_t f_ba(); return BA_B; endfunction
  function int   f_bb(); return BB_B; endfunction
  function eb0_t f_b0z(); return B0_A; endfunction      // the ZERO enumerator
  function ebc_t f_bc(); return BC_B; endfunction
  function ebd_t f_bd(); return BD_B; endfunction
  function ebe_t f_be(); return BE_B; endfunction
  function ebf_t f_bf(); return BF_B; endfunction
  function ebg_t f_bg(); return BG_B; endfunction
  function ebh_t f_bh(); return BH_B; endfunction
  function ebi_t f_bi(); return BI_B; endfunction
  function ebj_t f_bj(); return BJ_B; endfunction

  // a FUNCTION-LOCAL enum typedef
  function int f_loc();
    typedef enum { BL_A, BL_B } ebl_t;
    return BL_B;
  endfunction

endpackage
