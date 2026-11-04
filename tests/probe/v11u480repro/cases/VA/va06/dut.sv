// § fixArrLocalNamedAggElemTs480 (packed struct local array read by always_comb through a function)
module top(input logic [3:0] i, output logic [3:0] o);
  typedef struct packed { logic [1:0] hi; logic [1:0] lo; } op_t;
  function automatic logic [3:0] swap(input logic [3:0] n);
    op_t t[2];
    t[0] = n;
    t[1].hi = t[0].lo;
    t[1].lo = t[0].hi;
    return t[1];
  endfunction
  always_comb o = swap(i);
endmodule
