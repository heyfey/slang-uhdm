// § modAggTfArgLastWriter155
interface ifc;
  typedef union packed { logic [3:0] a; logic [3:0] b; } u_t;
  function automatic logic [3:0] f (u_t op); return op.a; endfunction
  function automatic logic [3:0] g (u_t op); return op.b; endfunction
endinterface
module top(input logic [3:0] i, output logic [3:0] o); ifc u(); assign o = u.g(i); endmodule
