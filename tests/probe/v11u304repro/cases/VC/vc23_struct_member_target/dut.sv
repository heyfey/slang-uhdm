// § genCaCastTdAliasScopedName304
module top (input logic [3:0] a, output logic [3:0] y);
  typedef logic [1:0] idx_t;
  typedef struct packed {logic [1:0] h; logic [1:0] l;} s_t;
  s_t s;
  if (1) begin : g
    assign s.l = idx_t'(a);
    assign s.h = 2'b0;
  end
  assign y = s;
endmodule
