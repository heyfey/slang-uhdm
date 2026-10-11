// § genCaCatMemberInst284
package pk;
  localparam logic [7:0] PP = 8'd3;
endpackage
module dut(input logic a, output logic [31:0] o);
  logic [31:0] w;
  assign o = w;
  if (1) begin : g
    assign w[3:0] = {pk::PP, 1'b0};
  end
endmodule
