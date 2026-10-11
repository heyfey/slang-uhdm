// § caHierSelBoundName282
module top #(parameter int BW = 2) (input logic [7:0] a, output logic y);
  struct packed { logic [7:0] addr; } st;
  assign st.addr = a;
  for (genvar g = 0; g < 1; g++) begin : gb
    assign y = st.addr[BW +: 1] & 1'b1;
  end
endmodule
