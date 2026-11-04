// § doWhileMacroCondEnd181 (v11u181 break: the whole do-while inside a macro, a condition macro expanding onto a later line, a do-while in a class method with a macro condition)
`define LOOP do j++; while (j < 3);
`define C2 (j <\
 9)
module top;
  int j;
  class K; int q; function void f(); do q++; while `C2; endfunction endclass
  initial begin
    `LOOP
    do j++; while `C2;
  end
endmodule
