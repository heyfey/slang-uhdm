// § genLocalEnumConstShared184: a generate case and an if/else pair, each block declaring its own enum or a variable of a module enum
module dut #(parameter int M = 1) (input logic clk, output logic [1:0] y);
  typedef enum logic [1:0] {S0, S1, S2} s_e;
  case (M)
    0: begin : c0
      s_e q;
      always_ff @(posedge clk) q <= S1;
      always_comb y = (q == S1) ? 2'd1 : 2'd0;
    end
    default: begin : cd
      typedef enum logic [1:0] {D0, D1} d_e;
      d_e q;
      always_ff @(posedge clk) q <= D1;
      always_comb y = (q == D1) ? 2'd2 : 2'd0;
    end
  endcase
  if (M > 5) begin : gi
    always_comb y = 2'd3;
  end else begin : ge
    s_e w;
    always_ff @(posedge clk) w <= (w == S0) ? S2 : S0;
  end
endmodule
