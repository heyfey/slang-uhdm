// § nonTrailIdxNamesByChain308
typedef struct packed { logic [7:0] f; } e_t;
module sub(output logic [3:0] o); assign o = 4'd2; endmodule
module top(output logic [7:0] r);
  e_t sa[16];
  sub u0(.o(imp));
  assign r = sa[imp + 1].f;
endmodule
