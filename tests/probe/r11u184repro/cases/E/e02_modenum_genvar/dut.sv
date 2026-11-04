// § genLocalEnumConstShared184 (control): a MODULE enum whose variable is declared in the generate block
module dut #(parameter bit P = 1'b1) (input logic clk, output logic [1:0] y);
  typedef enum logic [1:0] {S0, S1, S2} st_e;
  if (P) begin : g
    st_e q, d;
    always_comb begin
      d = q;
      case (q)
        S0: d = S1;
        default: d = S0;
      endcase
      y = (q == S2) ? 2'd1 : 2'd0;
    end
    always_ff @(posedge clk) q <= d;
  end
endmodule
