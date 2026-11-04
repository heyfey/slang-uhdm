// § defGenLhsHpBaseAnchor144
module dut(input logic [1:0] a, output logic [3:0] o);
  typedef struct packed { logic x; logic y; } in_t;
  typedef struct packed { in_t a; } s_t;
  s_t [1:0] s;
  for (genvar i = 0; i < 2; i++) begin : g
    assign s[i].a.x = a[i];
    assign s[i].a.y = ~a[i];
  end
  assign o = s;
endmodule
