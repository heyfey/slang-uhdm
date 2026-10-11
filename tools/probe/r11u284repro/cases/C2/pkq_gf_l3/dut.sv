// § genCaCatMemberInst284
package pk;
  localparam logic [7:0] PP = 8'd3;
endpackage
module dut(input logic a, output logic [31:0] o);
  logic [31:0] w;
  assign o = w;
  for (genvar i = 0; i < 2; i++) begin : g
    assign w[i] = {pk::PP, 1'b0};
  end
endmodule
