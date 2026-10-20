// § bitsDefNoFoldNoTs421
module top #(parameter w_p = 4, parameter W = $bits(logic [w_p:0])) (output logic [7:0] o);
  typedef struct packed { logic [w_p-1:0] d; logic b; } pk_s;
  parameter X = $bits(pk_s);
  assign o = X + W;
endmodule
