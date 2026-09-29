// § strLitContLineSpan220
class c;
  function string f();
    return "cls \
ret";
  endfunction
  task t(output string o);
    o = "cls \
asg";
  endtask
endclass
module top; endmodule
