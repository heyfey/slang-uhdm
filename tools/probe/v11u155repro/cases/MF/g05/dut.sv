// § modAggTfArgLastWriter155
interface ifc;
  typedef struct packed { logic [1:0] a; logic [1:0] b; } s_t;
  function automatic logic [1:0] f (s_t op); return op.a; endfunction
endinterface
module top(input logic [3:0] i, output logic [1:0] o);
  ifc u();
  assign o = u.f(i);
endmodule
