// § bitsDefNoFoldNoTs421
module c #(parameter w_p = 4) (output logic [7:0] o);
  typedef struct packed { logic [w_p-1:0] d; logic b; } pk_s;
  localparam W = $bits(pk_s);
  pk_s r;
  assign r = '1;
  assign o = W + r;
endmodule
module top (output logic [7:0] o1, o2); c #(.w_p(2)) u(o1); c v(o2); endmodule
