// arm a16: the FOR-HEADER LOOP VARIABLE in an uninstantiated interface, read
// in the SUBROUTINE road (§ uninstIfaceBodyBindsInMethodWindow218, which has
// shipped since r10uvm218) beside the PROCESS road this pass adds.  If golden
// leaves the loop variable bare in BOTH and the pristine binary already binds
// it in the SUBROUTINE column, the over-bind is a pre-existing defect of the
// shared expression road and not something the process road introduces.
interface if226_fv();
   int q226;
   int n226;

   function automatic int f226(int a226);
      int r226;
      for (int k226 = 0; k226 < a226; k226++)
         r226 += k226;
      return r226;
   endfunction

   task automatic t226(int a226);
      for (int k226 = 0; k226 < a226; k226++)
         q226 += k226;
   endtask

   initial begin
      for (int k226 = 0; k226 < n226; k226++)
         q226 += k226;
   end

   always_comb begin
      for (int k226 = 0; k226 < n226; k226++)
         q226 = k226;
   end
endinterface

module top226_fv;
   logic unused226;
endmodule
