// § caFoldParentUnboundLhs267
typedef struct packed { logic [5:0] q; logic e; } fld_t;
interface ifc #(parameter int W = 6);
  fld_t s;
  assign s.q = {W{1'b1}};
  assign s.e = 1'b1;
endinterface
module top(output fld_t o);
  ifc u_i();
  assign o = u_i.s;
endmodule
