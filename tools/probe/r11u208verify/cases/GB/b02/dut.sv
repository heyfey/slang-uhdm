// § genBlockBitsKeepsSelect200
module b02 #(parameter N = 2) (input logic [15:0] x, output logic [31:0] z);
  case (N)
    2: begin : c2
      logic [31:0] q;
      always_comb q = $bits(x[N*4-1:0]);
    end
    default: begin : cd
      logic [31:0] q;
      always_comb q = 0;
    end
  endcase
  assign z = c2.q;
endmodule
