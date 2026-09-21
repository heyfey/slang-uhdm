// r11u79 z3 — THE PACKAGE LISTING'S NET/VARIABLE DISCRIMINATOR, SPELLING BY
// SPELLING.  `emitPackage`'s current rule is "a TypeAlias whose canonical type
// is integral and not an enum is a NET; everything else a variable".  Surelog's
// rule is `NetlistElaboration::elabSignal` (NetlistElaboration.cpp:2074-2172),
// run over `pack->getSignals()` by `elaboratePackages` (:100-133): a signal
// whose elabSignal returns FALSE is ERASED from getSignals and lands in
// `netlist->variables()`; the survivors are written by `writeNets(pack, ...,
// instance=nullptr)` (UhdmWriter.cpp:1298 -> :812) — always a FLAT logic_net.
// This arm asks golden which written spelling lands in which vector.
package pt;
  typedef logic [3:0]                          word_t;
  word_t                                       t_word;    // one typedef hop
  typedef word_t                               word2_t;
  word2_t                                      t_word2;   // TWO hops
  typedef bit [3:0]                            bt_t;
  bt_t                                         t_bit;
  typedef reg [3:0]                            rg_t;
  rg_t                                         t_reg;
  typedef struct packed { logic [7:0] x; logic [7:0] y; } st_t;
  st_t                                         t_st;      // ALL-LOGIC struct
  typedef struct packed { int x; logic [7:0] y; }         si_t;
  si_t                                         t_si;      // an INT member
  typedef union  packed { logic [7:0] a; logic [7:0] b; } un_t;
  un_t                                         t_un;      // packed UNION
  typedef enum logic [1:0] { EA, EB }          en_t;
  en_t                                         t_en;
  typedef logic [1:0][7:0]                     parr_t;
  parr_t                                       t_parr;    // PACKED array
  typedef int                                  int_t;
  int_t                                        t_int;
  struct packed { logic [7:0] a; logic [7:0] b; }         t_anon;   // ANONYMOUS
  union  packed { logic [7:0] a; logic [7:0] b; }         t_anonu;
  typedef struct { logic [7:0] a; byte b; }    us_t;
  us_t                                         t_us;      // UNPACKED struct
  typedef union  { logic [7:0] a; byte b; }    uu_t;
  uu_t                                         t_uu;      // UNPACKED union
  typedef struct { logic [7:0] a; logic [7:0] b; }        usl_t;
  usl_t                                        t_usl;     // ALL-LOGIC unpacked struct
  typedef union  { logic [7:0] a; logic [7:0] b; }        uul_t;
  uul_t                                        t_uul;     // ALL-LOGIC unpacked union
  struct packed { int a; logic [7:0] b; }      t_anonsi;  // ANONYMOUS, an INT member
  struct { logic [7:0] a; logic [7:0] b; }     t_anonus;  // ANONYMOUS unpacked
endpackage

module dut (output logic [31:0] o);
  import pt::*;
  assign o = {28'd0, t_word} ^ {28'd0, t_word2} ^ {28'd0, t_bit} ^ {28'd0, t_reg}
           ^ {16'd0, t_st} ^ {16'd0, t_si} ^ {24'd0, t_un} ^ {30'd0, t_en}
           ^ {16'd0, t_parr} ^ t_int ^ {16'd0, t_anon} ^ {24'd0, t_anonu};
endmodule
