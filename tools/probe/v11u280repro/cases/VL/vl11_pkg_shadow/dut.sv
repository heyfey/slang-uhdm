// § genLoopDirectBoundPaCopy280
// a module localparam shadowing an imported package parameter of the same name
package pk; parameter logic [3:0] R4 = {2{2'b11}}; endpackage
module top import pk::*; (input logic [31:0] sig, output logic [1:0] o [2]);
  localparam logic [3:0] R4 = {2{2'b01}};
  for (genvar i = 0; i < 2; i++) begin : g
    assign o[i] = sig[R4 +: 2];
  end
endmodule
