// § caDelayFirstOnly164 — a delay list inside a gen-if block
module top (input a, output b, output c);
  if (1) begin : g
    assign #2 b = a, c = ~a;
  end
endmodule
