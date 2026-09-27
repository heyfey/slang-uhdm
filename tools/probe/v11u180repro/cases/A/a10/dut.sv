// § classTpDefaultTsAtUse180 (verifier: the default class declared later through a forward typedef; uses in a task block and a foreach)
package pkg;
  typedef class base_c;
  class holder #(type CB=base_c);
    CB m;
    CB arr[3];
    task run();
      begin
        CB blk;
        foreach (arr[i]) begin
          CB e;
          e = arr[i];
          blk = e;
        end
      end
    endtask
  endclass
  class base_c; int v; endclass
endpackage
module top();
pkg::holder c1;
endmodule
