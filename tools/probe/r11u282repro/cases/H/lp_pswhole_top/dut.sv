// § caHierSelBoundName282
package pk; parameter int BW = 2; endpackage
module top   (input logic [7:0] a, output logic y);
  localparam int BW = 2;
  struct packed { logic [7:0] addr; } st;
  assign st.addr = a;
  assign y = st.addr[BW:BW];
endmodule

