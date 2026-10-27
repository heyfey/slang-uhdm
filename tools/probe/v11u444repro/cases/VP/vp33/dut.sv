// § nestProgAbstain444v
module top;
  int y;
  program prg;
    task automatic t(); reg r; int y; r = 1'b1; y = r; endtask
    initial t();
  endprogram
  int z;
endmodule
