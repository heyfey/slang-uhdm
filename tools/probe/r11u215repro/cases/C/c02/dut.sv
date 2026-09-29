// § caseItemWildConcatOnly215 — plain wildcard literals of several bases in a function's case, x and z digits
package tp;
  parameter logic [7:0] WH = 8'h?3;
  parameter logic [3:0] WX = 4'b1x0?;
  parameter logic [3:0] WZ = 4'bz01?;
endpackage
module dut import tp::*; (input logic [7:0] a, output logic [1:0] o);
  function automatic logic [1:0] dec(input logic [7:0] v);
    casez (v)
      WH: return 2'd1;
      default: return 2'd0;
    endcase
  endfunction
  always_comb begin
    o = dec(a);
    casex (a[3:0])
      WX: o = 2'd2;
      WZ: o = 2'd3;
      default: ;
    endcase
  end
endmodule
