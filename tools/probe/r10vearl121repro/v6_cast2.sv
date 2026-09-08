module vcast2 (input logic [7:0] din, output logic [12:0] y1, output logic [12:0] y2, output logic [12:0] y3);
  typedef struct packed { logic a; logic [3:0] b; logic [7:0] c; } s_t;
  // n1 -- MODULE-LOCAL typedef, type-qualified pattern
  for (genvar i = 0; i < 1; i++) begin : n1
    s_t v;
    assign v = s_t'{a: 1'b1, b: 4'd3, c: din};
  end
  assign y1 = n1[0].v;
  // n2 -- type-qualified pattern with a GEN-LOCAL typedef
  for (genvar i = 0; i < 1; i++) begin : n2
    typedef struct packed { logic a; logic [3:0] b; logic [7:0] c; } g_t;
    g_t v;
    assign v = g_t'{a: 1'b0, b: 4'd4, c: din};
  end
  assign y2 = n2[0].v;
  // n3 -- plain pattern, module-local typedef (control)
  for (genvar i = 0; i < 1; i++) begin : n3
    s_t v;
    assign v = '{a: 1'b1, b: 4'd5, c: din};
  end
  assign y3 = n3[0].v;
endmodule
