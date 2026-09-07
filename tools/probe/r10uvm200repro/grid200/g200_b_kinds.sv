// r10uvm200 grid arm B — WHAT the reference names, and how it is spelled.
package pc200b;
  parameter WC = 3;
endpackage

package pa200b;
  import pc200b::*;
  parameter WLOC = 5;
  localparam WLP = 6;
  parameter int WTY = 7;
  typedef enum logic [3:0] {E0 = 4, E1 = 5} e200b_t;
  function logic [WLOC:0] k1(input logic [WLOC:0] a); k1 = a; endfunction
  function logic [WLP:0]  k2(input logic [WLP:0] a);  k2 = a; endfunction
  function logic [WTY:0]  k3(input logic [WTY:0] a);  k3 = a; endfunction
  function logic [E1:0]   k4(input logic [E1:0] a);   k4 = a; endfunction
  function logic [pc200b::WC:0] k5(input logic [pc200b::WC:0] a); k5 = a; endfunction
  function logic [WC:0]   k6(input logic [WC:0] a);   k6 = a; endfunction
  function logic [WLOC-1:0] k7(input logic [WLOC*2:0] a); k7 = a[WLOC-1:0]; endfunction
endpackage

package pb200b;
  import pa200b::*;
endpackage

module top200b;
  import pa200b::*;
  initial $display(WLOC);
endmodule
