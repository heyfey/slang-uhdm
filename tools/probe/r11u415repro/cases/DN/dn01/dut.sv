// § disableHierNetFirstName415
module sub;
  task Read; #5; endtask
endmodule
module top;
  function void interrupt();
    disable u1.Read;
  endfunction
  sub u1();
  initial interrupt();
endmodule
