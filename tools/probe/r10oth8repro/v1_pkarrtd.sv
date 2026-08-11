// VERIFIER-ADDED arm v1 — the hole no r10oth8 arm covers.
//
// § arrayVarSignedWritten8's clause (b) whitelists `PackedArrayType`, and
// clause (c) then calls `isSigned()` on it.  A packed array's signedness in
// slang comes from its ELEMENT, and that element may itself be a TYPEDEF NAME.
// So `typedef byte b_t; b_t [3:0] x[];` reaches (b) as a PackedArrayType and
// (c) as SIGNED -- i.e. the predicate PIERCES a typedef through the packed
// wrapper, which is exactly the behaviour the pass refuted for the bare case
// (a3 c01).  If golden gives these nothing, the predicate over-fires.
// v01/w01 are the test; v02/w02 (written `bit signed [7:0][3:0]`) is the
// POSITIVE control that must stay 1; v03/w03 uses a signed ENUM typedef.
typedef byte b_t;
typedef enum bit signed [3:0] { EA, EB } se_t;

class vc;
  b_t  [3:0] v01_pk_btd[];
  bit signed [7:0][3:0] v02_pk_written[];
  se_t [1:0] v03_pk_enumtd[];
endclass

module v1_top;
  b_t  [3:0] w01_pk_btd[];
  bit signed [7:0][3:0] w02_pk_written[];
  se_t [1:0] w03_pk_enumtd[];
  vc h;
  initial begin
    h = new();
    w01_pk_btd = new[1];
    w02_pk_written = new[1];
    w03_pk_enumtd = new[1];
  end
endmodule
