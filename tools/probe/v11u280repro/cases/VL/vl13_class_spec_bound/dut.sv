// § genLoopDirectBoundPaCopy280
// a class specialization's parameter as a bound beside the replication localparam
package pk; class c #(parameter int W = 2); endclass endpackage
module top (input logic [31:0] sig, output logic [1:0] o [2], output logic [1:0] p [2]);
  localparam logic [3:0] R4 = {2{2'b01}};
  for (genvar i = 0; i < 2; i++) begin : g
    assign o[i] = sig[R4 +: pk::c#(2)::W];
    assign p[i] = sig[R4 +: 2];
  end
endmodule
