// § genCaCatMemberInst284
package pk;
  localparam logic [63:0] P = 1;
endpackage
module dut(input logic a, output logic [31:0] o);
  if (1) begin : g
    logic [31:0] lv;
    assign lv = {pk::P, a};
    assign o = lv;
  end
endmodule
