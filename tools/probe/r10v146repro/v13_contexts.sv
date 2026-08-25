// A $unit-imported parameter used in a PORT WIDTH, a TYPE, a parameter DEFAULT,
// a class member, a function body and a task body.
package pv13;
  parameter int CW = 5;
endpackage
import pv13::*;
typedef logic [CW-1:0] cw_t;
module leaf_v13 #(parameter int LW = CW) (input logic [CW-1:0] i, output cw_t o);
  assign o = i + LW;
endmodule
module top_v13;
  cw_t a, b;
  leaf_v13 u (.i(a), .o(b));
  function automatic int fw(); return CW; endfunction
  task automatic tw(output int z); z = CW; endtask
  int q;
  initial begin
    q = fw();
    tw(q);
  end
endmodule
