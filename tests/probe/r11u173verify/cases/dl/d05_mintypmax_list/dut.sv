// § caDelayFirstOnly164 — a min:typ:max delay, two net assignments
module top (input a, output b, output c);
  assign #(1:2:3) b = a, c = ~a;
endmodule
