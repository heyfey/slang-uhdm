// § tfLocalClassArrElemClassTs452
class C;
  int x;
endclass
module sub;
  task t;
    C arr[2];
  endtask
endmodule
module top;
  sub u1();
  sub u2();
endmodule
