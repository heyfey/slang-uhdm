// § castPatTagKeyLocThroughParens302
// c05: a cast-wrapped pattern as a continuous assignment's right side
typedef struct packed { logic [7:0] n; logic [7:0] h; } cfg_t;
module dut (input logic [7:0] a, output cfg_t o);
  assign o = cfg_t'('{n: a, h: 8'h3});
endmodule
