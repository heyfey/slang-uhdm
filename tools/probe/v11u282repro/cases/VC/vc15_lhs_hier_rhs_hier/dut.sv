// § caHierSelBoundName282
module top #(parameter int BW = 2) (input logic [7:0] a, output logic [7:0] y);
  struct packed { logic [7:0] addr; } st, so;
  assign st.addr = a;
  assign so.addr[0] = st.addr[BW +: 1] ^ 1'b1;
  assign y = so.addr;
endmodule
