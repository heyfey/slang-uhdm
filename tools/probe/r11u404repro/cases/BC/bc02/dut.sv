// § subrBuiltinClassArrElemUnsup404
module top ();
  process mp;
  process ma[];
  task automatic t1 (int N);
    process p1;
    process p2[] = new [N];
    mailbox m1[] = new [N];
    semaphore s1[];
    process p3[$];
    p1 = process::self();
  endtask
endmodule
