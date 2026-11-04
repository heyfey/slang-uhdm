// § defGenLhsHpBaseAnchor144
module dut(input logic [1:0] a, output logic [3:0] o);
  typedef struct packed { logic f; logic g; } s_t;
  s_t [1:0] s;
  for (genvar i = 0; i < 2; i++) begin : g
    localparam int K = i;
    assign s[K].f = a[i];
    assign s[K].g = 1'b1;
  end
  assign o = s;
endmodule
