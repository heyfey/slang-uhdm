// § genBlockBitsKeepsSelect200
module sub #(parameter int S = 1) (input logic [31:0] x, output logic [31:0] z, output logic [31:0] y);
  case (S)
    1: begin : c1
      assign z = $bits(x[7:0]);
    end
    default: begin : c2
      assign z = 0;
    end
  endcase
  if (S == 2) begin : g
    assign y = 1;
  end else begin : h
    assign y = $bits(x[3]);
  end
endmodule
module top (input logic [31:0] x, output logic [31:0] z, output logic [31:0] y);
  sub u (.*);
endmodule
