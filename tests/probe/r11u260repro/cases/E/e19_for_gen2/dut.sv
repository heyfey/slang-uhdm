// § castStructInstCopy260 (the cast two for-generate levels down)
module m (input logic [31:0] w, output logic [5:0] o [2][2]);
  typedef struct packed {
    logic [25:0] a;
    logic [5:0]  x;
  } t_t;
  for (genvar i = 0; i < 2; i++) begin : gi
    for (genvar j = 0; j < 2; j++) begin : gj
      t_t r;
      assign r = t_t'(w);
      assign o[i][j] = r.x;
    end
  end
endmodule
module top;
  logic [31:0] w; logic [5:0] o [2][2];
  m u (.w(w), .o(o));
endmodule
