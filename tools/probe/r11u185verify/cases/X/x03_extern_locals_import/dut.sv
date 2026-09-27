// § importCloneBodyLocalCopies175 § externProtoFormalsFromPrototype175
package p1;
  class base;
    int q;
    extern task run(int n = 2, output int o);
    extern function int get(int k);
  endclass
  task base::run(int n = 2, output int o);
    int acc = 0;
    int arr [$];
    for (int i = 0; i < n; i++) arr.push_back(i);
    o = acc + arr.size();
  endtask
  function int base::get(int k);
    int t = k * 2;
    return t;
  endfunction
endpackage
package p2;
  import p1::*;
  int z;
endpackage
package p3;
  import p1::*;
endpackage
module top; import p2::*; initial z = 1; endmodule
