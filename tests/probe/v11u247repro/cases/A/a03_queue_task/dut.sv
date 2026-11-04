// § cloneArrTsHomeRefOwn247
package p;
  class c;
    int m;
    extern task t();
  endclass
  task c::t();
    c q[$];
    string names[string];
    q.push_back(this);
    foreach (q[i]) q[i].m = i;
    foreach (names[k]) m += names[k].len();
  endtask
endpackage
module top;
  import p::*;
  c z;
endmodule
