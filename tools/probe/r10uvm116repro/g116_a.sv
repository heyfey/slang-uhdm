// r10uvm116 arm A -- the HEAD shape: scope-form randomize with a constraint block,
// exactly as uvm_sequence_builtin.svh:97 writes it, inside a task of a class.
class packer_a;
  rand int unsigned k_alpha;
  rand int unsigned k_beta;
  int unsigned floor_a;
  int unsigned ceil_a;
  task run_alpha();
    if (!randomize(k_alpha) with { k_alpha > floor_a;
      k_alpha < ceil_a; })
      $display("alpha fail");
  endtask
  task run_beta();
    if (!randomize(k_beta) with { k_beta > floor_a && k_beta < ceil_a; })
      $display("beta fail");
  endtask
endclass
module top_a;
  packer_a p_alpha;
  initial begin
    p_alpha = new();
    p_alpha.run_alpha();
  end
endmodule
