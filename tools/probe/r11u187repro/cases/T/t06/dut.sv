// § trailIdxSelNamesByPath187
typedef struct packed { logic [7:0] f; } s_t;
module top #(parameter bit P = 1, parameter bit Q = 1) (input s_t s, input logic [2:0] i, output logic y);
  if (P) begin : ga
    if (Q) begin : gb
      logic w;
      always_comb w = s.f[i[1:0]];
    end
  end
  assign y = ga.gb.w;
endmodule
