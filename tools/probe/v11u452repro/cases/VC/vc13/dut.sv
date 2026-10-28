// § tfLocalClassArrElemClassTs452
class C;
  int x;
endclass
module top;
  if (1) begin : g
    task t;
      C arr[2];
    endtask
  end
endmodule
