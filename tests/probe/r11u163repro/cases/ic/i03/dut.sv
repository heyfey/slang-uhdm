// § importPatOpCloneParamNamed163
package ep;
  typedef struct packed { logic p; logic n; } tx_t;
endpackage
module gen #(parameter ep::tx_t D = '{p: 1'b1, n: 1'b0}) (output logic x);
  assign x = D.p;
endmodule
module top(output logic o);
  gen u(.x(o));
endmodule
