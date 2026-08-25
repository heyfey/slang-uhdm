// A MODULE-scope function body references a MODULE localparam that shadows the
// $unit wildcard import.  Different values on purpose.
package pv19;
  parameter int SZ = 40;
endpackage
import pv19::*;
module top_v19;
  localparam int SZ = 4;
  function automatic int f(); return SZ; endfunction
  task automatic t(output int o); o = SZ; endtask
  int a, b, c;
  initial begin
    a = f();
    t(b);
    c = SZ;
  end
endmodule
