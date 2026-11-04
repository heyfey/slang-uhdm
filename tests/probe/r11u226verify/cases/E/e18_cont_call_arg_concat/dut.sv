// § strLitContLineSpan220 — continued string literals as a task call argument, inside a concatenation and as a $display argument
module top(output string o);
  task automatic t(input string s); o = s; endtask
  initial begin
    t("arg \
one");
    o = {"cat \
two", "x"};
    $display("disp \
three %s", o);
  end
endmodule
