// § kwDirectiveSvMode237v
// begin_keywords 1800-2017 in a .v root
`begin_keywords "1800-2017"
module top(output [3:0] o);
  typedef struct packed { logic [1:0] g; bit [1:0] h; } s_t;
  s_t x;
  assign o = x;
endmodule
`end_keywords
