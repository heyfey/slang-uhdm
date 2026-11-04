// § genCaCatMemberInst284
package pk;
  localparam logic [7:0] PP = 8'd3;
endpackage
module dut import pk::*; (input logic a, output logic [31:0] o);
  logic [31:0] w;
  assign o = w;
  for (genvar i = 0; i < 1; i++) begin : g
    if (1) begin : g2
    logic [31:0] lv;
    assign lv = {PP, 1'b0};
    assign w[i] = lv[0];
    end
  end
endmodule
