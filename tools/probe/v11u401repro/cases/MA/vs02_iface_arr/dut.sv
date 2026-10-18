// § ifacePortArrMemberChainPath401
typedef struct packed { logic v; logic [2:0] t; } e_t;
interface IF; e_t ent [4]; modport m(input ent); endinterface
module consumer(IF.m w, output logic o, output logic [2:0] q);
  assign o = w.ent[1].v;
  assign q = w.ent[2].t;
endmodule
module top;
  IF i(); logic o; logic [2:0] q;
  consumer c(.w(i), .o(o), .q(q));
endmodule
