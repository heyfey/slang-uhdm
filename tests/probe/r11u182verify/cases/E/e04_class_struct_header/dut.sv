// § tsMemberRootFile171
package pc;
  class c;
    typedef struct packed {
`include "cs.svh"
    } s_t;
    s_t m;
    function new();
      m = '0;
    endfunction
  endclass
endpackage
module dut (input logic [7:0] i, output logic [7:0] o);
  assign o = i;
endmodule
