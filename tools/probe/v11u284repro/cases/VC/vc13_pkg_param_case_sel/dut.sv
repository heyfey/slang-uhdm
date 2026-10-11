// § genCaCatMemberInst284
package pk;
  localparam logic [63:0] P = 2;
endpackage
module dut(input logic a, output logic [31:0] o);
  logic [31:0] w;
  assign w[31:8] = 0;
  assign o = w;
  case (1)
    1: begin : g
      assign w[7:0] = {pk::P, a};
    end
  endcase
endmodule
