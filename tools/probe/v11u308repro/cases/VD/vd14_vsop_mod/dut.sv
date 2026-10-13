// § varSelIdxOpHpLeafByPath308
typedef struct packed { logic [3:0] q; logic [3:0][7:0] bin; } b_t;
module top(input logic [3:0] i, output logic [7:0] r);
  b_t bb; logic [3:0] two_d [4][4];
  assign r = bb.bin[two_d[1][bb.q + 1]];
endmodule
