// § genLocalEnumConstShared184: an enum constant of a generate-block typedef read in the block's process (copied from r11u171repro/evidence/residue/E, the ibex_multdiv_fast shape)
module dut #(parameter bit P = 1'b1) (input logic clk, input logic [1:0] a, output logic [1:0] y);
  if (P) begin : g
    typedef enum logic [1:0] {
      S0, S1, S2
    } st_e;
    st_e q, d;
    always_comb begin
      d = q;
      unique case (q)
        S0: begin d = S1; y = 2'd0; end
        S1: d = S2;
        default: d = S0;
      endcase
    end
    always_ff @(posedge clk) q <= d;
  end
endmodule
