// § caDelayFirstOnly164 — a rise/fall delay, two net assignments
module top (input a, output b, output c);
  assign #(1,2) b = a, c = ~a;
endmodule
