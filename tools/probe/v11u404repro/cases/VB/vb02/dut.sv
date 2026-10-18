// § builtinClassElemNotInClass404v
class worker;
  task run(int n);
    process jobs[] = new[n];
    mailbox #(int) mb[2];
    $display(jobs.size(), $size(mb));
  endtask
endclass
module top;
  initial begin worker w = new; w.run(3); end
endmodule
