// § caHierSelBoundName282
module top #(parameter int BW = 2) (input logic [7:0] a, output logic y);
  typedef struct packed { logic [7:0] addr; } in_t;
  struct packed { in_t inr; logic [3:0] k; } st;
  assign st.inr.addr = a; assign st.k = '0;
  assign y = |st.inr.addr[BW +: 1];
endmodule
