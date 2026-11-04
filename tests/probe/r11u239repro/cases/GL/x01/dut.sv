// § genLpSysCallArgName239
// case-generate item, $bits of a struct typedef, $clog2 of a genvar
module top #(parameter int N = 4) (input logic [N-1:0] r, output logic [3:0] o);
  typedef struct packed { logic [2:0] a; logic b; } s_t;
  case (N)
    4: begin : g4
      localparam int L = $bits(s_t);
      localparam int M = $clog2(N);
      assign o[0] = r[0] ^ (L > M);
    end
    default: begin : gd
      assign o[0] = r[0];
    end
  endcase
  for (genvar i = 1; i < 4; i++) begin : gf
    localparam int W = $clog2(i);
    assign o[i] = r[0] ^ (W > 0);
  end
endmodule
