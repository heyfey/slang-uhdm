// § kwDirectiveSvModeEnum237v
// pass 235's enum base under begin_keywords 1800-2017 in a .v root
`begin_keywords "1800-2017"
module top(output [1:0] o);
  typedef enum logic [1:0] {A, B} e_t;
  e_t x;
  assign o = x;
endmodule
`end_keywords
