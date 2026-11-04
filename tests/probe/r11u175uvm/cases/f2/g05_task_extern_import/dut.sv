package p1;
  class base;
    extern task run(int all);
  endclass
  task base::run(int all);
    string key;
    int arr[$];
    int id;
    arr.push_back(all);
    id = all;
  endtask
endpackage
package p2;
  import p1::*;
  int k;
endpackage
module top;
  import p2::*;
  initial k = 1;
endmodule
