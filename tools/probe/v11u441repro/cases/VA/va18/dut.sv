// § sysCallEmptyArgEndPrevTok441
module top;
  int a = 1, b = 2;
  for (genvar g = 0; g < 2; g++) begin : gb
    initial begin
      $display("x", a,
               , g);
    end
  end
endmodule
