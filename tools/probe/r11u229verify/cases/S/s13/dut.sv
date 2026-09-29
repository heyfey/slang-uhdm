// § strLitPpEscIdShift224 (a while condition, the body on the same line)
module top(output string o);
  initial begin
    o = "";
    while (o != "a\nb` c") o = "a\nb` c";
  end
endmodule
