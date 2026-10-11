// § caHierSelBoundName282
package pk; parameter int BW = 2; endpackage
module top  #(parameter int BW = 2) (input logic [7:0] a, output logic y);
  
  struct packed { logic [7:0] addr; } st;
  assign st.addr = a;
  assign y = st.addr[BW +: 1];
endmodule
module wrap(input logic [7:0] a, output logic y); top u (.a(a), .y(y)); endmodule
