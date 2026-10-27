// § progLocalDeclNets444
module top;
  prg p();
endmodule
program prg;
int x;
task automatic t();
  int loc;
  loc = x;
endtask
function automatic int f(); int fl; fl = 3; return fl; endfunction
initial begin t(); x = f(); end
endprogram
