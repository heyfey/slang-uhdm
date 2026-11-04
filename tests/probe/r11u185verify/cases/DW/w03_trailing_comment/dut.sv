// § doWhileSpansToCloseParen175 § doWhileEndsAtCondEnd178v
module top;
  int i, j;
  initial begin
    do i++; while (i < 3) /* c */ ;
    do j++; while (j < 3); // done
    do begin
      i--;
    end while (i > 0 /* tail */
    );
  end
endmodule
