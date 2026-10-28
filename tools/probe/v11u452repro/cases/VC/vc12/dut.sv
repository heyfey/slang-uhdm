// § tfLocalClassArrElemClassTs452
interface ifc;
  class C;
    int x;
  endclass
  task t;
    C arr[2];
  endtask
endinterface
module top;
  ifc u();
endmodule
