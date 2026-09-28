// § genHopFoldSelName198
module top #(parameter int N = 2) (input logic [15:0] a, output logic [3:0] y);
  typedef struct packed { logic [7:0] f; logic [7:0] g; } st_t;
  st_t st;
  assign st = a;
  for (genvar i = 0; i < 4; i++) begin : g
    localparam int unsigned L = i;
    if (N > 1) begin : h
      assign y[i] = st.f[L] | st.g[L+1];
    end
  end
endmodule
