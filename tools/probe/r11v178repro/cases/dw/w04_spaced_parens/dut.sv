// § doWhileEndsAtCondEnd178v
module top;
  int i, j, k;
  initial begin
    do i++; while ( i < 3 );
    do j++; while (j < 3 /* c */);
    do k++; while ((k < 3));
    do begin k--; end while (k>0) ;
  end
endmodule
