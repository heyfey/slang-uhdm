// v115_d — the CONTROL: user classes/typedefs that merely SHARE the names.
package pd_pkg;
  class process;                      // a USER class named `process`
    int x;
  endclass
  class semaphore;
    int y;
  endclass
  class mailbox;
    int z;
  endclass
  function automatic void pd_fn();
    process up;                       // resolves to the USER class
    semaphore us;
    mailbox um;
    up = new();
    us = new();
    um = new();
  endfunction
endpackage

module md_top;
  import pd_pkg::*;
  initial begin
    process up2;
    up2 = new();
  end
endmodule
