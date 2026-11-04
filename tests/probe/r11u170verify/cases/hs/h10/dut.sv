// § hpSelRoute157
typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
module top (input s_t s, input logic [15:0] v, output logic [3:0] q [2]);
  for (genvar g = 0; g < 2; g++) begin : G
    always_comb q[g] = v[s.a +: 4] ^ {3'b0, v[s.b]};
  end
endmodule
