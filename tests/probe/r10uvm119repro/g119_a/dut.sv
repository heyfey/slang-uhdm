// arm A — the head's shape: MEMBER randomize with a constraint block
class txn_a;
  rand int unsigned k_alpha;
  rand int unsigned k_beta;
  int unsigned lim_a;
endclass

class drv_a;
  txn_a seq_or_item;
  int unsigned bound_a;
  task run_a();
    txn_a local_item;
    local_item = new();
    if (!seq_or_item.randomize() with { k_alpha > 3; k_alpha < 17; }) begin
      bound_a = 1;
    end
    if (!local_item.randomize() with { k_beta inside {1, 2, 5}; }) begin
      bound_a = 2;
    end
  endtask
endclass

module top_a;
  drv_a d_a;
  initial begin
    d_a = new();
    d_a.run_a();
  end
endmodule
