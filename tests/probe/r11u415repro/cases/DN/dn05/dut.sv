// § disableHierNetFirstName415
interface bus;
  task Write; #5; endtask
endinterface
module top;
  bus sb();
  initial disable sb.Write;
endmodule
