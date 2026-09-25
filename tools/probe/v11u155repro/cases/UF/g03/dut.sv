// § unitAggTfArgLastWriter155
typedef union packed { logic [3:0] a; logic [3:0] b; } u_t;
function automatic logic [3:0] f (u_t op); return op.a; endfunction
module top(input logic [3:0] i, output logic [3:0] o);
  function automatic logic [3:0] h (u_t op); return op.b; endfunction
  assign o = f(i) ^ h(i);
endmodule
