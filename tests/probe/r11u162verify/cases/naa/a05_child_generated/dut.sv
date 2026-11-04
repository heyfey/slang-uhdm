// § nonAnsiArrayNetAtHeader155
module sub(a, o);
  input wire [3:0] a [0:2];
  output wire [3:0] o;
  assign o = a[0] + a[2];
endmodule
module top(input wire [3:0] a [0:2], output wire [3:0] o);
  if (1) begin : g
    sub u (a, o);
  end
endmodule
