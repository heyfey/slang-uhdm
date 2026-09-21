// v11u79 q2 — NET KEYWORD x BUILTIN DATA TYPE, LEGAL SPELLINGS ONLY.  slang
// rejects a 2-state net type ("'int' is not a valid type for a net"), so the
// LAW B comment table's `wire bit [7:0] -> bit_var` row is unreachable; the
// 4-state integer keywords below are the whole reachable face.
// pkgTypespecOverride79 gives PredefinedIntegerType an arm only for `byte`
// (2-state, hence unreachable behind a net keyword too), so every one of
// these keeps the declaration's net answer.  Does golden?
package q2;
  wire integer      n_integer;
  wire time         n_time;
  wire logic signed [7:0] n_logicsigned;
  wand logic [3:0]  n_wandlogic;
  wand integer      n_wandinteger;
  wor  [3:0]        n_worplain;
  supply0           n_sup0;
  supply1           n_sup1;
  uwire [1:0]       n_uwire;
  trireg [1:0]      n_trireg;
  tri0 [1:0]        n_tri0;
  tri1 [1:0]        n_tri1;
  triand [1:0]      n_triand;
  trior [1:0]       n_trior;
  tri [1:0]         n_tri;
  wire signed [7:0] n_wiresigned;
  integer           v_integer;
  time              v_time;
  byte              v_byte;
  shortint          v_shortint;
  longint           v_longint;
endpackage

module dut (output logic [31:0] o);
  import q2::*;
  assign o = n_integer ^ {28'd0, n_wandlogic} ^ {28'd0, n_worplain}
           ^ {31'd0, n_sup0} ^ {31'd0, n_sup1} ^ {30'd0, n_uwire}
           ^ {30'd0, n_trireg} ^ {30'd0, n_tri0} ^ {30'd0, n_tri1}
           ^ {30'd0, n_triand} ^ {30'd0, n_trior} ^ {30'd0, n_tri}
           ^ {24'd0, n_logicsigned} ^ n_wandinteger
           ^ {24'd0, n_wiresigned} ^ v_integer ^ {24'd0, v_byte}
           ^ {16'd0, v_shortint};
endmodule
