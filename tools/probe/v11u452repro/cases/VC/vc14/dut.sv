// § tfLocalClassArrElemClassTs452
class C;
  int x;
endclass
program prg;
  task t;
    C arr[2];
  endtask
endprogram
module top;
  prg p();
endmodule
