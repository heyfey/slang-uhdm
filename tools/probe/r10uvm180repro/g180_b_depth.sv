// r10uvm180 arm B — THE DEPTH AND SHAPE GRID.
// The same scalar typedef bound at every block shape the emitter can produce
// and at depths 1..5, in a body that is CLONED by a wildcard import.  If the
// law's reach were the hand-rolled descent it started as, one of these shapes
// would be the one it forgot.
package dz180_source;

  typedef logic [23:0] pumice_lt;

  function automatic int unsigned pumice_deep(pumice_lt inlet, int span);
    pumice_lt hold;
    hold = inlet;
    if (span > 0) begin                        // d1  if
      pumice_lt d1v;
      d1v = hold;
      for (int a = 0; a < span; a++) begin     // d2  for
        pumice_lt d2v;
        d2v = d1v + pumice_lt'(a);
        while (d2v[0] == 1'b1) begin           // d3  while
          pumice_lt d3v;
          d3v = d2v >> 1;
          case (d3v[1:0])                      // d4  case item
            2'b00: begin
                     pumice_lt d4v;
                     d4v = d3v ^ 24'h00_00_01;
                     forever begin             // d5  forever
                       pumice_lt d5v;
                       d5v = d4v;
                       d3v = d5v;
                       break;
                     end
                   end
            default: d3v = d3v + 1;
          endcase
          d2v = d3v;
        end
        d1v = d2v;
      end
      hold = d1v;
    end
    else begin                                  // d1  else arm
      pumice_lt e1v;
      e1v = ~hold;
      hold = e1v;
    end
    return int'(hold);
  endfunction

  function automatic int unsigned pumice_forked(pumice_lt inlet);
    pumice_lt hold;
    hold = inlet;
    begin : mantle
      pumice_lt named1;
      named1 = hold;
      hold = named1;
    end
    return int'(hold);
  endfunction

  function automatic int unsigned pumice_each(pumice_lt inlet);
    pumice_lt hold;
    pumice_lt tray [4];
    hold = inlet;
    foreach (tray[k]) begin
      pumice_lt f1v;
      f1v = hold + pumice_lt'(k);
      tray[k] = f1v;
      hold = f1v;
    end
    return int'(hold);
  endfunction

  // the EXPRESSION role at three shapes: a call argument, a condition operand,
  // and a cast operand.
  function automatic int unsigned pumice_expr(pumice_lt inlet);
    if (pumice_deep(inlet, 2) > 0)
      return pumice_each(inlet);
    return int'(pumice_forked(inlet));
  endfunction

endpackage

package dz180_taker;
  import dz180_source::*;
endpackage

module dz180_top;
  import dz180_source::*;
  pumice_lt gantry;
  int unsigned ledger;
  initial begin
    gantry = 24'h12_34_56;
    ledger = pumice_expr(gantry);
  end
endmodule
