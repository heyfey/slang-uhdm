// § modEnumTfArgCloneFollows299
module m (input logic [1:0] d, output logic o);
  typedef enum logic [1:0] { BA, BB, BC } b_e;
  typedef struct packed { b_e op; logic [1:0] sz; } b_t;
  b_t bv;
  function automatic logic f(input b_e q); return q == BA; endfunction
  assign bv = {b_e'(d), 2'b0};
  assign o = f(bv.op);
endmodule
module top (input logic [1:0] d, output logic o);
  m u (.d(d), .o(o));
endmodule
