// § disableHierNetFirstName415
interface ifc;
  task Read; #5; endtask
endinterface
module top;
  ifc i1();
  task stop;
    disable i1.Read;
  endtask
  initial stop();
endmodule
