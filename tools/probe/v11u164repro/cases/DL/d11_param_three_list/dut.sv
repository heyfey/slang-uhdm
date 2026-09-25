// § caDelayFirstOnly164 — a parameter delay, three net assignments, plus an undelayed statement
module top #(parameter D = 6) (input a, output b, c, d, e);
  assign #D b = a, c = ~a, d = a;
  assign e = a;
endmodule
