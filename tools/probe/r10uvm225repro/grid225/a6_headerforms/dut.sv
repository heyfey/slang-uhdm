// r10uvm225 arm a6_headerforms — is the array_net law gated on the HEADER
// FORM the way the typespec law is?  The four forms, same declarations.
class Ch225;
  int x;
endclass
typedef logic [7:0] tvh225_t;

// EMPTY PARENS
interface if225_ep();
  Ch225    e_dyncls225 [];
  tvh225_t e_astv225   [string];
  int      e_fixint225 [2];
  int      e_qint225   [$];
endinterface

// ANSI header
interface if225_ansi(input logic clk225);
  Ch225    a_dyncls225 [];
  tvh225_t a_astv225   [string];
  int      a_fixint225 [2];
  int      a_qint225   [$];
endinterface

// GENUINE NON-ANSI port list
interface if225_na(pa225);
  input pa225;
  Ch225    n_dyncls225 [];
  tvh225_t n_astv225   [string];
  int      n_fixint225 [2];
  int      n_qint225   [$];
endinterface

// NO PARENS AT ALL
interface if225_np;
  Ch225    o_dyncls225 [];
  tvh225_t o_astv225   [string];
  int      o_fixint225 [2];
  int      o_qint225   [$];
endinterface

module top225_hdr(); endmodule
