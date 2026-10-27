// § sysCallEmptyArgEndPrevTok441
module top;
  int a = 1, b = 2;
  initial begin
    $display("x", a, /* one */ /* two */
             , b);
    $display("x", a,
      /* three */ , b);
    $display("x", a,  /* four
      five */ , b);
  end
endmodule
