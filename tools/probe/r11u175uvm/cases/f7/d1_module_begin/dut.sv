module top;
  int i;
  initial begin
    i = 0;
    do begin
      i = i + 1;
    end while (i < 3);
  end
endmodule
