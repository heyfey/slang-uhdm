// § genHopFoldSelName198: one-hop folds as the index of an unpacked element, of a member-select base and of a two-dimensional select
module top #(parameter int N = 2) (input logic [3:0] m [8], input logic [3:0] m2 [8][2], input logic [15:0] a, output logic [3:0] y [4], output logic [3:0] z [4], output logic w [4]);
  typedef struct packed { logic a; logic b; } s_t;
  s_t [7:0] st;
  assign st = a;
  for (genvar i = 0; i < 4; i++) begin : g
    localparam int unsigned L = i*2;
    if (N > 1) begin : h
      assign y[i] = m[L];
      assign z[i] = m2[L][0];
      assign w[i] = st[L].a;
    end
  end
endmodule
