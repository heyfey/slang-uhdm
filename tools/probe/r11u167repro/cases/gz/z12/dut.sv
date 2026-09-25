// § genProcFoldDeclTsScopeNamed167
package p;
  localparam int PW = 8;
  localparam logic [PW-1:0] PZ = 8'h5a;
endpackage
module top import p::*; (input logic clk, output logic [7:0] q);
  if (1) begin : g
    always_ff @(posedge clk) q <= PZ;
  end
endmodule
