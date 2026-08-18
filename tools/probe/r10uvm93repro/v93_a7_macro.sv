// v93 A7 — macro BODY literal vs macro ARGUMENT vs plain source.
`define BODY_INT(V)  { << int  { V } }
`define BODY_T(V)    { << mt7  { V } }
`define ARG_T(T, V)  { << T    { V } }
module a7_macro;
  typedef logic [7:0] mt7;
  logic [63:0] v, r0, r1, r2, r3, r4;
  initial begin
    r0 = `BODY_INT(v);
    r1 = `BODY_T(v);
    r2 = `ARG_T(int, v);
    r3 = `ARG_T(mt7, v);
    r4 = { << int { v } };
  end
endmodule
