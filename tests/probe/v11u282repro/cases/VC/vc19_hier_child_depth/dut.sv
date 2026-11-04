// § caHierSelBoundName282
module leaf #(parameter int BW = 2) (input logic [7:0] a, output logic y);
  struct packed { logic [7:0] addr; } st;
  assign st.addr = a;
  assign y = |st.addr[BW +: 1];
endmodule
module mid(input logic [7:0] a, output logic y); leaf #(.BW(3)) l(.a(a), .y(y)); endmodule
module top(input logic [7:0] a, output logic y); mid m(.a(a), .y(y)); endmodule
