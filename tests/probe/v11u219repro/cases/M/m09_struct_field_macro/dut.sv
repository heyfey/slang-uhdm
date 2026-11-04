// § ppDotNameAfterArgToken219 § ppIdentEndInRebuiltText219 — module RTL: a struct field selected through a macro actual (one line, forwarded through a second macro, and in a multi-line body)
typedef struct packed { logic [3:0] f; logic [2:0] gg; } s_t;
`define FLD(S) S.f
`define FLD2(S) `FLD(S)
`define SUMF(A, B) \
  (A.gg + \
   B.gg)
module top(input s_t st, input s_t su, output logic [3:0] o1, output logic [3:0] o2, output logic [2:0] o3);
  assign o1 = `FLD(st);
  assign o2 = `FLD2(su);
  assign o3 = `SUMF(st, su);
endmodule
