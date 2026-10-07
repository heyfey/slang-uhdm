// § genLoopDirectBoundPaCopy280
// a header parameter with a replication default, a width bound and a genvar-scaled base
module top #(parameter logic [3:0] P = {2{2'b01}}, parameter logic [1:0] W = {2{1'b1}})
  (input logic [63:0] sig, output logic [3:0] o [2]);
  for (genvar i = 0; i < 2; i++) begin : g
    assign o[i] = sig[P*i +: 4] ^ sig[P +: W];
  end
endmodule
