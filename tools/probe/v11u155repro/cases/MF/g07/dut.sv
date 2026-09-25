// § modAggTfArgLastWriter155
module top(input logic [3:0] i, output logic [3:0] o);
  typedef struct packed { logic [1:0] a; logic [1:0] b; } s_t;
  if (1) begin : g
    function automatic logic [1:0] f (s_t op); return op.a; endfunction
    assign o[1:0] = f(i);
  end
  function automatic logic [1:0] h (s_t op); return op.b; endfunction
  assign o[3:2] = h(i);
endmodule
