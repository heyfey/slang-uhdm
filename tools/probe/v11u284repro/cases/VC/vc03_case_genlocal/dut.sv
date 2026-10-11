// § genCaCatMemberInst284
module dut(input logic a, output logic [31:0] o);
  localparam logic [63:0] P = 1;
  localparam int M = 2;
  case (M)
    2: begin : g
      logic [31:0] lv;
      assign lv = {P, a};
      assign o = lv;
    end
    default: begin : d
      assign o = 0;
    end
  endcase
endmodule
