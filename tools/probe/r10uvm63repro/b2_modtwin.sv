// r10uvm63 arm b2 — THE MODULE-SCOPE TWIN of every b1 cell.
//
// WHY IT EXISTS.  § arrayElemTsSignedParented9's whole shape came from the
// element position being right at CLASS scope but wrong at MODULE scope (and
// the reverse for § arrayVarSignedWritten8 at subroutine scope).  A law stated
// over "the index typespec" is only a law if the module twin reads the same;
// if it does not, the fix is scope-bound and the other producer
// (TypeEmit.cpp / ParamEmit.cpp) is a separate call site with its own gate.
//
// The names are m<NN>_ mirroring c<NN>_ one for one.
module b2_top;
  int m01_integer[integer];
  int m02_int[int];
  int m03_byte[byte];
  int m04_shortint[shortint];
  int m05_longint[longint];
  int m06_time[time];
  int m07_intu[int unsigned];
  int m08_byteu[byte unsigned];
  int m09_integeru[integer unsigned];
  int m10_shortintu[shortint unsigned];
  int m11_longintu[longint unsigned];
  int m12_bit[bit];
  int m13_logic[logic];
  int m14_reg[reg];
  int m15_string[string];
  int m16_bitvec[bit [7:0]];
  int m17_logicvec[logic [7:0]];
  int m18_bitsvec[bit signed [7:0]];
  int m19_logicsvec[logic signed [7:0]];
  int m20_intsigned[int signed];
  int m21_bytesigned[byte signed];
endmodule
