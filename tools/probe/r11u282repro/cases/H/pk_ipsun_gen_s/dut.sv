// § caHierSelBoundName282
package pk; parameter int BW = 2; endpackage
module top import pk::*;  (input logic [7:0] a, output logic y, output logic [1:0] yv);
  struct packed { logic [7:0] addr; } st;
  assign st.addr = a;
  if (1) begin : g
    
    assign yv[0] = |st.addr[BW +: 1];
  end
endmodule
module wrap(input logic [7:0] a, output logic y, output logic [1:0] yv); top u (.a(a), .y(y), .yv(yv)); endmodule
