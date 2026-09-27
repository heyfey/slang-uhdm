// § doWhileSpansToCloseParen175 § doWhileEndsAtCondEnd178v
module top;
  int i, j;
  initial begin
    do
      do j++; while (j < 2);
    while (i++ < 3);
    do begin
      do begin j--; end while ((j > 0));
    end while (i-- > 0);
  end
endmodule
