// § methRecvElemCumName310
class item; int f; int k; function int get(); return f; endfunction endclass
class holder; item arr[4]; int idx[4]; int k; endclass
module top;
  item it[4]; holder hm; int r; int i;
  initial begin
    r = it[hm.k].get();
    r = it[hm.idx[i]].get();
    r = hm.arr[hm.k].get();
  end
endmodule
