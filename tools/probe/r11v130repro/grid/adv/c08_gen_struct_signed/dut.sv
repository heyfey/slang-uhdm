// § suSigningNotInSpan130
module top;
  if (1) begin : g
    struct packed signed { logic [3:0] a; logic [3:0] b; } s;
    assign s = '0;
  end
endmodule
