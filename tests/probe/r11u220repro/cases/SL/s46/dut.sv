// § strLitContLineSpan220
module top(output string o);
  function automatic string f();
    return "abc \
def";
  endfunction
  initial o = f();
endmodule
