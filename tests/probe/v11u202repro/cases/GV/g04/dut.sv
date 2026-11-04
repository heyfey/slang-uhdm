// § defGenInitBitSelAtIndex202
module g04 #(parameter N = 2) (input logic [7:0] x, output logic [N-1:0] o);
  for (genvar i = 0; i < N; i++) begin : gf
    logic a = x[i];
    logic b = x[i+1];
    assign o[i] = a ^ b;
  end
  case (N)
    2: begin : gc
      logic c = x[7];
    end
    default: ;
  endcase
endmodule
