// § doWhileMacroCondEnd181 (v11u181 break: do-while conditions through macros: function-like, nested macro, a macro closing the parenthesis, a multi-line body)
`define C(x) (x < 5)
`define D `C(j)
`define LT j <
module top;
  int j;
  initial begin
    do j++; while `C(j);
    do j++; while `D;
    do begin
      j++;
    end while (`LT 7);
    do j--; while (j > `C(1));
  end
endmodule
