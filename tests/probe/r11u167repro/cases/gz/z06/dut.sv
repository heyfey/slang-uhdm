// § genProcFoldDeclTsScopeNamed167
package p;
  localparam int PW = 8;
endpackage
module top #(parameter logic [p::PW-1:0] Z = '0) (input logic clk, output logic [7:0] q);
  if (1) begin : g
    always_ff @(posedge clk) q <= Z;
  end
endmodule
