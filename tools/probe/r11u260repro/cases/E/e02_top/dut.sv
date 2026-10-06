// § castStructInstCopy260 (the cast in the top module)
module top (input logic [31:0] w, output logic [5:0] o);
  typedef struct packed {
    logic [25:0] a;
    logic [5:0]  x;
  } t_t;
  t_t rd, wd;
  assign rd.a = '0;
  assign wd = t_t'(w);
  assign o = wd.x;
endmodule
