// arm B — MEMBER randomize WITHOUT a with-block (the NAME rule uvm116 left open)
class txn_b;
  rand int unsigned q_one;
  rand int unsigned q_two;
endclass

class drv_b;
  txn_b recv_b;
  int unsigned ok_b;
  task run_b();
    ok_b = recv_b.randomize();
    ok_b = recv_b.randomize(q_one);
    ok_b = recv_b.randomize(q_one, q_two);
    ok_b = recv_b.randomize(null);
  endtask
endclass

module top_b;
  drv_b e_b;
  initial begin
    e_b = new();
    e_b.run_b();
  end
endmodule
