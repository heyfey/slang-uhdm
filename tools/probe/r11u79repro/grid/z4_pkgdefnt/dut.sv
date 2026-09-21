// r11u79 z4 — LAW C ON THE PACKAGE'S OWN LISTING: the vpiNetType a package
// NET carries.  `writeNets` stamps `getVpiNetType(orig_net->getType())`
// (UhdmWriter.cpp:891, table at :572) — the WRITTEN base keyword through
// exactly one typedef hop, `vpiNone` for an implicit/signed/packed-dimension
// spelling and 0 for everything the table has no arm for.  Only a signal whose
// elabSignal returned TRUE reaches this vector at all, so every row here is
// BOTH a discriminator reading and a net-type reading.  `var`-qualified and
// `const` spellings are asked too (r11v77's residue 2 on the module side).
package pd;
  wire   [7:0]  d_wire;
  tri    [7:0]  d_tri;
  tri0          d_tri0;
  tri1          d_tri1;
  triand [7:0]  d_triand;
  trior  [7:0]  d_trior;
  trireg [7:0]  d_trireg;
  wand   [7:0]  d_wand;
  wor    [7:0]  d_wor;
  supply0       d_sup0;
  supply1       d_sup1;
  uwire  [7:0]  d_uwire;
  wire signed [7:0] d_wsigned;
  logic  [7:0]  d_logic;
  reg    [7:0]  d_reg;
  integer       d_integer;
  time          d_time;
  bit    [7:0]  d_bit;
  var logic [7:0] d_varlog;
  const logic [7:0] d_constlog = 8'd3;
  typedef logic [3:0] w_t;
  w_t           d_tdlog;
  typedef w_t   w2_t;
  w2_t          d_tdlog2;
  typedef struct packed { logic [7:0] x; logic [7:0] y; } st_t;
  st_t          d_struct;
  wire   st_t   d_wstruct;
  typedef enum logic [1:0] { EA, EB } en_t;
  en_t          d_enum;
  typedef union packed { logic [7:0] a; logic [7:0] b; } un_t;
  un_t          d_union;
  wire   un_t   d_wunion;
  wire logic [7:0] d_wlogic;      // a net KEYWORD with a data-type keyword
  wand integer  d_wandint;        // the "wand integer" spelling Surelog names
  wire   w_t    d_wtd;            // a net keyword + a ONE-HOP typedef
  wire   w2_t   d_wtd2;           // a net keyword + a TWO-HOP typedef
endpackage

module dut (output logic [31:0] o);
  import pd::*;
  assign o = {24'd0, d_wire} ^ {24'd0, d_logic} ^ {24'd0, d_reg}
           ^ d_integer ^ {24'd0, d_bit} ^ {28'd0, d_tdlog}
           ^ {16'd0, d_struct} ^ {30'd0, d_enum} ^ {24'd0, d_union};
endmodule
