// § progLocalDeclNets444
module m;
int x;
task automatic t();
  int loc;
  loc = x;
endtask
initial t();
endmodule
