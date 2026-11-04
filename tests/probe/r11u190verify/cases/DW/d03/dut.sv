// § doWhileMacroCondEnd181 § doWhileSyntaxFromCond181 (r11u190: nested do-whiles whose conditions are calls, one through a macro)
`define MORE(v) (more(v))
module top;
  int j, k;
  function automatic bit more(int n); return n < 3; endfunction
  initial begin
    do begin
      do k++; while (more(k));
      j++;
    end while `MORE(j);
    do begin
      do k--; while `MORE(k);
    end while (more(j));
  end
endmodule
