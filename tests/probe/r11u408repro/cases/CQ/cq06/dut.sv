// § classBoundedQueueStatic408
class Fifo #(type T = logic, int DEPTH = 1);
  T myFifo [$:DEPTH-1];
  function void put(T a);
    myFifo.push_back(a);
  endfunction
endclass
module top;
endmodule
