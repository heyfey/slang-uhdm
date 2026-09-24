// § suSigningNotInSpan130
module top;
  logic [7:0] r;
  initial begin
    struct packed signed { logic [3:0] a; logic [3:0] b; } s;
    s = 8'd5;
    r = s;
  end
endmodule
