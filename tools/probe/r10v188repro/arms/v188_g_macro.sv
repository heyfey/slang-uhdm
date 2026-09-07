// r10v188repro/arms/v188_g_macro.sv — LEAVES THE RENDERER MUST NOT MISREAD.
// The renderer takes each literal leaf's SOURCE TEXT through `rawText`.  A
// MACRO-EXPANDED leaf, an underscore inside a BASED literal, a leaf under a
// CAST, a 20-digit decimal, and a leaf spelled with interior whitespace are the
// five ways that text can stop being the literal itself.
`define V188G_W 4
`define V188G_LIT 8'h0F
`define V188G_EXPR 1 << 5

package v188g_pkg;
  typedef enum longint unsigned {
    G_MACSH  = 1 << `V188G_W,
    G_MACLIT = `V188G_LIT + 2,
    G_MACALL = `V188G_EXPR,
    G_USEP   = 8'h1_0 + 3,
    G_USEP2  = 1_2 + 3,
    G_CAST   = int'(2) + 3,
    G_LONG   = 12345678901234567890 + 0,
    G_WS     = 8'h 1F + 2,
    G_TICKSZ = 4'h3 + 1
  } v188g_e;
endpackage
