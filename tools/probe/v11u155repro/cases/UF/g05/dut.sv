// § unitAggTfArgLastWriter155
typedef struct packed { logic [3:0] a; } s_t;
function automatic logic [3:0] f (s_t op); return op.a; endfunction
module top(input logic [3:0] i, output logic [3:0] o);
  function automatic logic [3:0] h (s_t op); return op.a; endfunction
  s_t w; assign w = i;
  assign o = f(w) ^ h(i);
endmodule
