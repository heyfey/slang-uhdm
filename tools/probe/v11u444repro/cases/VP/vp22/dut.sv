// § nestProgAbstain444v
module top;
  logic a;
  program prg;
    int x;
    task automatic t(); int loc; loc = x; endtask
    initial t();
  endprogram
endmodule
