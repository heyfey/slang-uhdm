// § castStructInstCopy260 (a package struct typedef cast in an instance)
package p;
  typedef struct packed {
    logic [25:0] a;
    logic [5:0]  x;
  } t_t;
endpackage
module m (input logic [31:0] w, output logic [5:0] o);
  p::t_t rd, wd;
  assign rd.a = '0;
  assign wd = p::t_t'(w);
  assign o = wd.x;
endmodule
module top;
  logic [31:0] w; logic [5:0] o;
  m u (.w(w), .o(o));
endmodule
