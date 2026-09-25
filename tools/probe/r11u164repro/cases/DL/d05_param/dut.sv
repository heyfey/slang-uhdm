// § caDelayFirstOnly164 — a parameter delay, two net assignments
module top #(parameter D = 3) (input a, output b, output c);
  assign #D b = a, c = ~a;
endmodule
