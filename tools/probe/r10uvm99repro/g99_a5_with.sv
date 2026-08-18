// r10uvm99 arm a5: `inside` in the WITH clause of array locator/reduction
// methods, on a QUEUE and on a DYNAMIC ARRAY, class scope and module scope.
typedef struct { int fa; int fb; } rec99_t;
class epsilon99;
  rec99_t qlist [$];
  rec99_t rq99 [$];
  int dyn99 [];
  int res99 [$];
  int idx99 [$];
  int tot99;
  function void mfind();
    rq99   = qlist.find(itx) with (itx.fa inside {[1:3]});
    idx99  = qlist.find_index(itx) with (itx.fb inside {2, [4:6]});
    rq99   = qlist.find_first(itx) with (itx.fa inside {[7:9]});
    rq99   = qlist.find_last(itx) with (itx.fa inside {[0:1]});
    idx99  = dyn99.find_index(jtx) with (jtx inside {[5:7]});
    res99  = dyn99.find(jtx) with (jtx inside {3, [8:10]});
    tot99  = dyn99.sum(jtx) with ((jtx inside {[1:4]}) ? 1 : 0);
    res99  = dyn99.min(jtx) with (jtx inside {[2:5]});
    res99  = dyn99.max(jtx) with (jtx inside {[2:5]});
    res99  = dyn99.unique(jtx) with (jtx inside {[6:8]});
  endfunction
endclass
module zeta99b;
  int mq99 [$];
  int mr99 [$];
  initial begin
    mr99 = mq99.find(ktx) with (ktx inside {[1:3]});
  end
endmodule
