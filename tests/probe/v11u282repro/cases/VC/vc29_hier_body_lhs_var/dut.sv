// § caHierSelBoundName282
module top #(parameter int BW = 2) (input logic [7:0] a, output logic [1:0] y);
  struct packed { logic [7:0] addr; } st;
  logic [1:0] t;
  assign st.addr = a;
  assign t = st.addr[BW +: 2] ^ 2'd3;
  assign y = t;
endmodule
