// § caHierSelBoundName282
interface ifc #(parameter int BW = 2) (input logic [7:0] a);
  struct packed { logic [7:0] addr; } st;
  assign st.addr = a;
  logic y;
  assign y = |st.addr[BW +: 1];
endinterface
module top(input logic [7:0] a, output logic y); ifc i(.a(a)); assign y = i.y; endmodule
