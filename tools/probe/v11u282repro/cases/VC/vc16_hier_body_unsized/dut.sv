// § caHierSelBoundName282
module top #(parameter int BW = 2) (input logic [7:0] a, output logic [7:0] y);
  struct packed { logic [7:0] addr; } st;
  assign st.addr = a;
  assign y[1:0] = st.addr[BW +: 2] | '0;
endmodule
