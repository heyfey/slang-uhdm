// § castTsPushLaidOut131 (decode only, ground A: Earlgrey testflags #403326, the elaborated cast target struct shares the members a member path already reached)
module m (input logic [31:0] w, output logic [5:0] o);
  typedef struct packed {
    logic [25:0] a;
    logic [5:0]  x;
  } t_t;
  t_t wd;
  assign wd = t_t'(w);
  assign o = wd.x;
endmodule
module top;
  logic [31:0] w; logic [5:0] o;
  m u (.w(w), .o(o));
endmodule
