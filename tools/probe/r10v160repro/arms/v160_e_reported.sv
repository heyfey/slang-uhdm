// r10v160 arm E — THE REPORTED TWIN.  The SAME bad operand written where slang
// DOES diagnose it (a plain, non-generic class).  Both binaries must REFUSE
// this file identically (a non-zero rc); the law must not silently "recover"
// a REPORTED error into a database.  MEASUREMENT ONLY.
package pve160;
  class baseve160;
    function new(string name="x"); endfunction
  endclass
  class holdve160 extends baseve160;
    static string se = "";
    function void m(); int t; se = {"[", t.gt(), "]"};   endfunction
  endclass
endpackage

module topve160;
  initial $display("hi");
endmodule
