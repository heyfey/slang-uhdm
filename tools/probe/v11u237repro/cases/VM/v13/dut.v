// § kwDirectiveSvModeEnum237v
// pass 235's byte enum base under begin_keywords 1800-2017 in a .v root
`begin_keywords "1800-2017"
module top(output [7:0] o);
  typedef enum byte {A, B} e_t;
  e_t x;
  assign o = x;
endmodule
`end_keywords
