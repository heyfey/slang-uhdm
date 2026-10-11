// § genCaCatMemberInst284
module dut(input logic a, output logic [31:0] o);
  localparam P = 3;
  logic [31:0] w;
  assign o = w;
  case (1) 1: begin : g
    assign w[3:0] = {P, 1'b0};
  end default: begin : h end endcase
endmodule
