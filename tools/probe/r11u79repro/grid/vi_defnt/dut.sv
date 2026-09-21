// v11u77 vi -- LAW C face: the DEF-VIEW vpiNetType spellings y5 did not ask.
// pkgVarDeclNetType77 reads the declaration's written base keyword through
// exactly ONE typedef hop and answers 36 for `logic`, 48 for `reg`, 0 else.
package pd;
  typedef reg  [3:0]  r_t;
  typedef bit  [3:0]  b_t;
  typedef logic       ls_t;       // scalar logic typedef
  typedef logic [3:0] w_t;
  typedef w_t         w2_t;       // the ONE hop, measured: none
  logic signed [7:0]  d_lsgn;
  reg   signed [7:0]  d_rsgn;
  var   logic  [7:0]  d_varlog;
  logic               d_lscal;
  reg                 d_rscal;
  int unsigned        d_intu;
  shortint            d_short;
  longint             d_long;
  r_t                 d_tdreg;
  b_t                 d_tdbit;
  ls_t                d_tdlscal;
  w_t                 d_tdw;
  w2_t                d_tdw2;
  logic [3:0][7:0]    d_pkd2;
endpackage

module dut (output logic [31:0] o);
  import pd::*;
  assign o = {24'd0, d_lsgn} ^ {24'd0, d_rsgn} ^ {24'd0, d_varlog}
           ^ {31'd0, d_lscal} ^ {31'd0, d_rscal} ^ d_intu
           ^ {16'd0, d_short} ^ d_long[31:0]
           ^ {28'd0, d_tdreg} ^ {28'd0, d_tdbit} ^ {31'd0, d_tdlscal}
           ^ {28'd0, d_tdw} ^ {28'd0, d_tdw2} ^ d_pkd2;
endmodule
