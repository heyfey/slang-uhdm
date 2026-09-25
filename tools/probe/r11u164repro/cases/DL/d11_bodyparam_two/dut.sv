// § caDelayFirstOnly164 — a body-parameter delay, two net assignments
module top (input a, output b, output c);
  parameter D = 3;
  assign #D b = a, c = ~a;
endmodule
