// § genCaCatMemberInst284
package pk;
  localparam logic [7:0] PP = 8'd3;
endpackage
module dut(input logic a, output logic [31:0] o);
  logic [31:0] w;
  if (1) begin : g
    logic [31:0] lv;
    assign lv = {pk::PP, 1'b0};
    assign o = lv;
  end
endmodule
