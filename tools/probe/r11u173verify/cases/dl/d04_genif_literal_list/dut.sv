// § caDelayFirstOnly164 — a literal delay, two net assignments inside a gen-if block
module top (input a, output b, output c);
  if (1) begin : g
    assign #3 b = a, c = ~a;
  end
endmodule
