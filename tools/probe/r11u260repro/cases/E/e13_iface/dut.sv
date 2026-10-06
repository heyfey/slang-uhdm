// § castStructInstCopy260 (the cast in an interface body)
interface ifc (input logic [31:0] w);
  typedef struct packed {
    logic [25:0] a;
    logic [5:0]  x;
  } t_t;
  t_t rd, wd;
  assign rd.a = '0;
  assign wd = t_t'(w);
endinterface
module top;
  logic [31:0] w;
  ifc u (.w(w));
endmodule
