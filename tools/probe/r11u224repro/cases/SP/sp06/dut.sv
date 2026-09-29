// § strLitPpEscIdShift224
module top(output string o);
  function string f();
    return "a\nb` c";
  endfunction
  assign o = f();
endmodule
