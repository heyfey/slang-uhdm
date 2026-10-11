// § caHierSelBoundName282
module top #(parameter int BW = 2) (input logic [7:0] a, output logic y);
  typedef struct packed { logic [7:0] addr; } s_t;
  s_t st [2];
  assign st[0].addr = a; assign st[1].addr = a;
  assign y = |st[1].addr[BW +: 1];
endmodule
