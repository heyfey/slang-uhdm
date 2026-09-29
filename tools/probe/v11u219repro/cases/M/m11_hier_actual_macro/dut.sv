// § ppDotNameAfterArgToken219 § ppIdentEndInRebuiltText219 — a hierarchical actual `u.r` followed by a member from the macro body, and a forwarded bit-select actual
module sub(output logic [3:0] r);
  assign r = 4'd3;
endmodule
`define PICK(I, M) I.M
`define TOP(I) `PICK(I, r)
module top(output logic [3:0] o1, output logic o2);
  sub u();
  assign o1 = `TOP(u);
  assign o2 = `PICK(u, r[1]);
endmodule
