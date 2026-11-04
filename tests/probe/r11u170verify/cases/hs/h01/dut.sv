// § hpSelRoute157
typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
module top #(parameter s_t Cfg = '{a: 4'd2, b: 4'd1}) (input s_t s, input logic [15:0] mem, output logic [3:0] q, output logic [3:0] r);
  for (genvar i = 0; i < 4; i++) begin : G
    assign q[i] = s.a[i] & mem[s.b];
    assign r[i] = mem[Cfg.a +: 2] == s.b[1:0];
  end
endmodule
