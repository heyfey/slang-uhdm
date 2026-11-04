// § defGenLhsHpBaseAnchor144
module top(input logic [1:0] v, output logic o);
  typedef struct packed { logic f; logic g; } s_t;
  s_t [3:0] s;
  if (1) begin : gi
    localparam int K = 2;
    assign s[K].f = v[0];
    assign s[K].g = v[1];
  end
  for (genvar i = 0; i < 2; i++) begin: g
    for (genvar j = 0; j < 2; j++) begin: h
      assign s[i*2+j].f = 1'b0;
    end
  end
  assign o = s[2].f;
endmodule
