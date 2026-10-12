// § varDeclInitElabSpan297
typedef struct packed { logic [1:0] a; logic b; } t_t;
module dut(output logic [2:0] o);
  module inner(output logic [2:0] q);
    var t_t x = 3'b101;
    assign q = x;
  endmodule
  inner ui(.q(o));
endmodule
