// § caDelayFirstOnly164 — an expression delay over a parameter, two net assignments
module top #(parameter D = 1) (input a, output b, output c);
  assign #(D + 1) b = a, c = ~a;
endmodule
