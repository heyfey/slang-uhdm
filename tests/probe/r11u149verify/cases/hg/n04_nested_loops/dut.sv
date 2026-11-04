// § defGenLhsHpBaseAnchor144
module dut(input logic [3:0] a, output logic [7:0] o);
  typedef struct packed { logic f; logic g; } s_t;
  s_t [1:0][1:0] s;
  for (genvar i = 0; i < 2; i++) begin : gi
    for (genvar j = 0; j < 2; j++) begin : gj
      assign s[i][j].f = a[i*2+j];
      assign s[i][j].g = 1'b0;
    end
  end
  assign o = s;
endmodule
