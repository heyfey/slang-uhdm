// § caHierSelBoundName282
module top #(parameter int BW = 4) (input logic [7:0] a, output logic [1:0] y);
  struct packed { logic [7:0] addr; } st;
  assign st.addr = a;
  assign y = st.addr[BW -: 2] + 2'd1;
endmodule
