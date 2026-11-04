// § genLocalEnumConstShared184 (control, r11v184's residue R2): a compilation-unit enum read in generate-for and generate-case processes with no block variable (only a module variable)
typedef enum logic [1:0] {UA, UB, UC} ue_t;
module top #(parameter int K = 2) (input logic clk, output logic [1:0] y);
  ue_t m;
  for (genvar i = 0; i < 1; i++) begin : gf
    always_ff @(posedge clk) m <= (m == UA) ? UB : UC;
  end
  case (K)
    2: begin : gc
      always_comb y = (m == UC) ? 2'd3 : 2'd0;
    end
    default: begin : gd
      assign y = 2'd1;
    end
  endcase
endmodule
