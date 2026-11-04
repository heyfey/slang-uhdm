// § caHierSelBoundName282
module top #(parameter int BW = 2) (input logic [7:0] a, input logic c, output logic [1:0] y);
  struct packed { logic [7:0] addr; } st;
  assign st.addr = a;
  assign y = c ? st.addr[BW +: 2] : 2'd0;
endmodule
