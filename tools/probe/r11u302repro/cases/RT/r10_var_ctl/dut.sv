// § rootTdLeftoverStamp302
// r10: CONTROL - a $root typedef with no builder (a variable and a pattern localparam)
typedef struct packed { int unsigned a; int unsigned b; } rc_t;
module dut(output logic o);
  localparam rc_t L = '{a: 1, b: 2};
  rc_t v;
  assign v = L;
  assign o = v.a[0];
endmodule
