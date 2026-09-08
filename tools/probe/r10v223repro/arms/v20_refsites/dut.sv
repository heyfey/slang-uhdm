// v20 — every REFERENCE SITE for an imported name inside an interface:
// a continuous assign, an always block, a function body and a task body,
// uninstantiated (if_v20u) and instantiated (if_v20i).
package pv20;
  logic [3:0] lv20;
  int iv20;
endpackage

interface if_v20u;
  import pv20::*;
  logic [3:0] own_u20;
  int cnt_u20;
  assign own_u20 = lv20;
  always_comb cnt_u20 = iv20;
  function automatic int fu20(); return iv20; endfunction
  task automatic tu20(); cnt_u20 = iv20; endtask
endinterface

interface if_v20i;
  import pv20::*;
  logic [3:0] own_i20;
  int cnt_i20;
  assign own_i20 = lv20;
  always_comb cnt_i20 = iv20;
  function automatic int fi20(); return iv20; endfunction
endinterface

module top_v20;
  if_v20i u_if();
endmodule
