// § ppOutputLine166 § ppOutputCol166 § tagPatSortSrcOrder177v
`define ADD2(x, y) \
  ((x) + \
   (y))
module top (input logic [3:0] a, input logic [3:0] c, output logic [7:0] b);
  typedef struct packed { logic [3:0] x; logic [3:0] y; } s_t;
  s_t s;
  assign s = '{y: c, x: `ADD2(a,
                             c)};
  assign b = s;
endmodule
