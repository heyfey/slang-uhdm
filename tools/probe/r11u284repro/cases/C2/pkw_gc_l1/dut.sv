// § genCaCatMemberInst284
package pk;
  localparam logic [7:0] PP = 8'd3;
endpackage
module dut import pk::*; (input logic a, output logic [31:0] o);
  logic [31:0] w;
  case (1) 1: begin : g
    logic [31:0] lv;
    assign lv = {PP, 1'b0};
    assign o = lv;
  end default: begin : h end endcase
endmodule
