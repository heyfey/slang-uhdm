// § importPatOpCloneParamNamed163
package ep;
  typedef struct packed { logic p; logic n; } tx_t;
  parameter tx_t TX_DEFAULT = '{p: 1'b0, n: 1'b1};
endpackage
module gen import ep::*; (output logic x);
  assign x = TX_DEFAULT.n;
endmodule
module mid(output logic x); gen g(.x(x)); endmodule
module top(output logic o1, o2);
  mid m1(.x(o1));
  mid m2(.x(o2));
endmodule
