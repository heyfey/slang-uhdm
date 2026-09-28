// § genBlockBitsKeepsSelect200
module top(input logic [15:0] x, output logic [31:0] z, output logic [31:0] z2);
  for (genvar i = 0; i < $bits(x[1:0]); i++) begin : g
    if ($bits(x[3:0]) == 4) begin : h
      assign z2 = $bits(x[i]);
    end
  end
  case ($bits(x[2:0]))
    3: begin : c assign z = $bits(x[4:0]); end
    default: begin : d assign z = 0; end
  endcase
endmodule
