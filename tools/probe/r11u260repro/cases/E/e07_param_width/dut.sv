// § castStructInstCopy260 (a member width from a module parameter)
module m #(parameter int W = 6) (input logic [31:0] w, output logic [W-1:0] o);
  typedef struct packed {
    logic [31-W:0] a;
    logic [W-1:0]  x;
  } t_t;
  t_t rd, wd;
  assign rd.a = '0;
  assign wd = t_t'(w);
  assign o = wd.x;
endmodule
module top;
  logic [31:0] w; logic [3:0] o;
  m #(.W(4)) u (.w(w), .o(o));
endmodule
