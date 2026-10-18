// § subrBuiltinClassArrElemUnsup404
module top;
  task automatic t1;
    mailbox m[$];
    semaphore s[3];
    $display(m.size(), $size(s));
  endtask
  function automatic int f1;
    process p[2];
    return $size(p);
  endfunction
  initial begin t1; $display(f1()); end
endmodule
