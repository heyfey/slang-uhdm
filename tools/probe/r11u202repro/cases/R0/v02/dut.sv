// § defGenInitRhsKeepsParent200
module v02 #(parameter K = 1)(input logic [7:0] m, output logic [7:0] o);
  logic [7:0] q;
  case (K)
    1: begin
      logic [7:0] a = q ^ 8'h1;
    end
    default: begin : d
      logic [7:0] b = q;
    end
  endcase
  for (genvar i = 0; i < 2; i++) begin : gf
    logic [7:0] e = q >> i;
  end
  assign o = m;
endmodule
