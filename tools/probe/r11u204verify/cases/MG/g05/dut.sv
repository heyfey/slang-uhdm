// § modGenericClassListed196 § modGenericHandleBare196: a program home with a value parameter, the default handle, a specialization and a task formal
program prg ();
  class ctr #(int MAX = 10);
    int n;
    function void inc(); if (n < MAX) n++; endfunction
  endclass
  ctr c0;
  ctr #(20) c1;
  task automatic run(ctr #(20) h);
    h.inc();
  endtask
endprogram
module top;
  prg p ();
endmodule
