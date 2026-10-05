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
package q;
  import p::*;
  class u;
    function void g();
      int x;
      x = 0;
    endfunction
  endclass
endpackage
module top;
  import p::*;
  import q::*;
  u w;
  c z;
endmodule
