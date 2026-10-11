// § caHierSelBoundName282
package pk; parameter int BW = 2; endpackage
module top import pk::*;  (input logic [7:0] a, output logic y);
  
  struct packed { logic [7:0] addr; } st;
  assign st.addr = a;
  assign y = st.addr[BW +: 1] & 1'b1;
endmodule

