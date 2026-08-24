// v119 arm K — the receiver's class reached through a PACKAGE (the two-file
// split of this arm was measured separately and is not committed: a lone
// second file is not self-contained and would read NONDETERMINISTIC to a
// future boundary gate).
package pk_k;
  class it_k;
    rand int unsigned k_a;
    rand int unsigned k_b;
  endclass
endpackage

class drv_k;
  pk_k::it_k r_k;
  int unsigned out_k;
  task run_k();
    if (!r_k.randomize() with { k_a > 1; }) out_k = 1;
    if (!r_k.randomize(k_a) with { k_a < 9; }) out_k = 2;
    if (!r_k.randomize()) out_k = 3;
  endtask
endclass

module top_k;
  drv_k d_k;
  initial begin
    d_k = new();
    d_k.run_k();
  end
endmodule
