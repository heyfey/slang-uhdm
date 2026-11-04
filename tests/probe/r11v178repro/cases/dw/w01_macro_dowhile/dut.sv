// § doWhileEndsAtCondEnd178v
`define DW(v) do v = v + 1; while (v < 3);
`define C (i < 5)
module top;
  int i, j;
  initial begin
    `DW(i)
    do j++; while `C;
    do begin
      j--;
    end while (
      j > 0
    );
  end
endmodule
