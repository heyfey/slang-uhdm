// § caHierSelBoundName282
module top #(parameter int BW = 2) (input logic [7:0] a, output logic y);
  struct packed { logic [7:0] addr; } st;
  assign st.addr = a;
  wire w = |st.addr[BW +: 1];
  assign y = w;
endmodule
module wrap(input logic [7:0] a, output logic y); top u (.a(a), .y(y)); endmodule
