// v11u80 q7 -- THE BOUNDARY.  The builder's ground is the module's copy of an
// IMPORTED PACKAGE variable.  Everything else that spells an unpacked array
// must be byte-identical between the two binaries: the module's OWN unpacked
// arrays, an interface's, a function's locals, a class property, a generate
// block's, and a package array reached by an EXPLICIT (non-wildcard) import
// and by a QUALIFIED reference with no import at all.
package pq7;
  typedef struct packed { int x; logic [7:0] y; } si_t;
  logic [7:0] g_plain [0:1];
  si_t        g_si    [0:1];
  logic [7:0] g_2d    [0:1][0:2];
endpackage

package pq7b;
  logic [7:0] h_plain [0:1];
  logic [7:0] h_other [0:1];
endpackage

interface ifq (input logic clk);
  logic [7:0] i_arr [0:1];
  modport mp (input clk);
endinterface

class cq;
  logic [7:0] c_arr [0:1];
  function automatic logic [7:0] f(int i);
    logic [7:0] l_arr [0:1];
    l_arr[0] = c_arr[0];
    return l_arr[0];
  endfunction
endclass

module dut (input logic clk, output logic [31:0] o);
  import pq7::*;            // wildcard: the builder's ground
  import pq7b::h_plain;     // EXPLICIT import of one name

  logic [7:0] m_own  [0:1];             // the module's own
  logic [7:0] m_own2 [0:1][0:2];
  ifq u_if (.clk(clk));

  function automatic logic [7:0] mf(int i);
    logic [7:0] fl [0:1];
    fl[0] = m_own[0];
    return fl[0];
  endfunction

  for (genvar gi = 0; gi < 1; gi = gi + 1) begin : gb
    logic [7:0] gen_arr [0:1];
    assign gen_arr[0] = m_own[0];
  end

  assign o = {24'd0, g_plain[0]} ^ {24'd0, g_si[0].y} ^ {24'd0, g_2d[0][0]}
           ^ {24'd0, h_plain[0]} ^ {24'd0, pq7b::h_other[0]}
           ^ {24'd0, m_own[0]} ^ {24'd0, m_own2[0][0]}
           ^ {24'd0, u_if.i_arr[0]} ^ {24'd0, mf(0)}
           ^ {24'd0, gb[0].gen_arr[0]};
endmodule
