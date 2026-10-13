// § nestShapeThroughVarSel308
typedef struct packed { logic [7:0] fv; } f_t;
typedef struct packed { logic [3:0] q; } q_t;
module top(input logic [3:0] n, output logic [7:0] r);
  q_t bb; f_t sa [16]; logic [3:0] two_d [4][4];
  assign r = sa[n + two_d[1][bb.q]].fv;
endmodule
