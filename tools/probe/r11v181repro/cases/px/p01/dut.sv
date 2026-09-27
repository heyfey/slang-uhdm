// § bitSelParenIdxSpan181 (v11u181 break: constant, cast, nested and spaced parenthesized indices on rvalues)
module top(input logic [7:0] a, input logic [2:0] i, output logic [7:0] y);
  always_comb begin
    y[0] = a[(2)];
    y[1] = a[( i )];
    y[2] = a[(int'(i))];
    y[3] = a[((i) + 1)];
    y[4] = a[(i) + 1];
    y[5] = a[(i)] ^ a[((i))];
  end
endmodule
