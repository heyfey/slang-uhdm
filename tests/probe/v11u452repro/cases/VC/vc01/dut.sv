// § tfLocalClassArrElemClassTs452
class C;
  int x;
endclass
module top;
  task t;
    C arr[4];
    arr[0] = new;
  endtask
endmodule
