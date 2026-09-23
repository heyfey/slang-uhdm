module m(input logic [3:0] o, output logic [3:0] y [2]);
  typedef struct packed { logic [15:0] f; } s_t;
  s_t s [2];
  assign s[0] = '0; assign s[1] = '1;
  for (genvar i = 0; i < 2; i++) begin : g
    assign y[i] = s[i].f[o +: 4];
  end
endmodule
