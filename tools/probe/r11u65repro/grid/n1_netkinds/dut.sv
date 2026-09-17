// r11u65 n1 — THE DEF-VIEW vpiNetType OF A NET DECLARED WITH AN UNPACKED-ARRAY
// TYPEDEF, per ELEMENT KIND and per CONTAINER KIND.  One module body, one
// declaration per cell.  Surelog's rule under test (ElaborationStep.cpp:1488)
// keys on the RESOLVED typedef's own base VObjectType and IGNORES dimensions.
module dut #(
    parameter int unsigned N = 2,
    parameter int unsigned D = 4
) (
    output logic [N-1:0] o
);
  // --- element kinds under ONE unpacked dimension -------------------------
  typedef logic  [N-1:0] a_t  [D];      // logic element          -> expect 36
  typedef reg    [N-1:0] r_t  [D];      // reg element            -> expect 48
  typedef bit    [N-1:0] b_t  [D];      // bit element (control)  -> expect 0
  typedef int            i_t  [D];      // int element (control)  -> expect 0
  typedef logic          l_t  [D];      // SCALAR logic element   -> expect 36
  typedef logic signed [N-1:0] sg_t [D];// signed logic element
  typedef logic  [N-1:0][7:0] tw_t [D]; // packed 2-D element

  // --- chained / named element -------------------------------------------
  typedef logic  [N-1:0] v_t;           // plain packed typedef
  typedef v_t            nm_t [D];      // element = NAMED typedef

  // --- non-vector elements (controls) ------------------------------------
  typedef struct packed { logic [N-1:0] f; } sp_t;
  typedef sp_t           sa_t [D];      // struct element
  typedef enum logic [1:0] { E0, E1 } en_t;
  typedef en_t           ea_t [D];      // enum element

  // --- container kinds (queue/dynamic/associative are arm n6) -------------
  typedef logic  [N-1:0] rg_t [D-1:0];  // RANGED unpacked dim
  typedef logic  [N-1:0] d2_t [D][2];   // TWO unpacked dims

  a_t  a;   r_t  r;   b_t  b;   i_t  i;   l_t  l;
  sg_t sg;  tw_t tw;  nm_t nm;
  sa_t sa;  ea_t ea;
  rg_t rg;  d2_t d2;

  // --- the same shapes WITHOUT a typedef, and WITH a declaration dim ------
  logic [N-1:0] pl [D];                 // no typedef at all
  a_t           ad [2];                 // typedef dim + declaration dim
  v_t           vd [D];                 // packed typedef + declaration dim

  assign o = a[0] | r[0] | {N{b[0][0]}} | {N{i[0][0]}} | {N{l[0]}} | sg[0] |
             tw[0][0] | nm[0] | sa[0].f | {N{ea[0][0]}} |
             rg[0] | d2[0][0] | pl[0] | ad[0][0] | vd[0];
endmodule
