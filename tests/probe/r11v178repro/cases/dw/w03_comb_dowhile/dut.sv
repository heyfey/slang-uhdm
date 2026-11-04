// § doWhileSpansToCloseParen175
module top(input logic [3:0] a, output logic [3:0] y);
  always_comb begin
    int k;
    k = 0;
    y = a;
    do begin y = y + 1; k++; end while (k < 2);
  end
endmodule
