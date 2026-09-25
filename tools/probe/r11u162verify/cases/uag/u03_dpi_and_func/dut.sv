// § unitAggTfArgLastWriter155
typedef struct packed { logic [3:0] a; } s_t;
function automatic logic [3:0] f (s_t op); return op.a; endfunction
module top(input logic [3:0] i, output logic [3:0] o);
  import "DPI-C" function void g (input s_t x);
  assign o = f(i);
endmodule
