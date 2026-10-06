// § caFoldParentUnboundLhs267
typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
interface ifc #(parameter int W = 4) ();
  s_t s;
  assign s.a = {W{1'b1}};
endinterface
module top;
  ifc u_i();
endmodule
