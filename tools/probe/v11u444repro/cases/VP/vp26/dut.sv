// § progLocalDeclNets444
program prg;
int x;
task automatic t();
  int loc;
  loc = x;
endtask
initial t();
endprogram
module top;
  prg p1();
  prg p2();
endmodule
