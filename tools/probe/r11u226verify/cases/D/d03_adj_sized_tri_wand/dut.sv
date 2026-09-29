// § ndaAdjSizeFoldSized223 — generic-handler $size values folded by the adjuster into a tri net, a wor net and a net typed by a packed struct typedef
module top(output logic [7:0] o1, output logic [7:0] o2, output logic [5:0] o3);
  typedef struct packed { logic [2:0] a; logic [2:0] b; } ps_t;
  bit [3:0][1:0] bp;
  byte by [3];
  tri [7:0] t1 = $size(bp);
  wor [7:0] t2 = $size(by, 2);
  wire ps_t t3 = $size(bp, 2);
  assign o1 = t1; assign o2 = t2; assign o3 = t3;
endmodule
