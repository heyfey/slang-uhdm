// v9_instshape — THE DANGEROUS DIRECTION.  The law fires on
// `defAllInstCount[&def] == 0`.  If any INSTANTIATION SHAPE that Surelog
// elaborates (so golden BINDS) were missed by that counter, the flag would go
// up and we would decline a binding golden HAS — a MISSING-OURS, an AWAY move.
// Every shape here is instantiated in a way a naive counter could miss:
// inside a GENERATE block, as an interface ARRAY, and nested inside a child
// module rather than the top.  All three must keep their enum actuals BOUND.
package v9pkg;
  typedef enum logic [1:0] { G_A = 2'd0, G_B = 2'd1, G_C = 2'd2 } g_e;
endpackage

interface v9_gen_if (input logic clk);          // instantiated INSIDE a generate
  import v9pkg::*;
  typedef enum logic [2:0] { GA_X = 3'd0, GA_Y = 3'd1 } ga_e;
  function automatic ga_e f(input int k);
    if (k == 0) return GA_X;
    case (k) 1: return GA_Y; default: return GA_X; endcase
  endfunction
  function automatic int s(input int k); return k + int'(G_A); endfunction
endinterface

interface v9_arr_if (input logic clk);          // instantiated as an ARRAY
  import v9pkg::*;
  typedef enum logic [2:0] { AR_X = 3'd0, AR_Y = 3'd1 } ar_e;
  function automatic ar_e f(input int k);
    if (k == 0) return AR_X;
    return AR_Y;
  endfunction
  function automatic int s(input int k); return k + int'(G_B); endfunction
endinterface

interface v9_deep_if (input logic clk);         // instantiated in a CHILD module
  import v9pkg::*;
  typedef enum logic [2:0] { DP_X = 3'd0, DP_Y = 3'd1 } dp_e;
  function automatic dp_e f(input int k);
    if (k == 0) return DP_X;
    return DP_Y;
  endfunction
  function automatic int s(input int k); return k + int'(G_C); endfunction
endinterface

module v9_child (input logic clk);
  v9_deep_if u_deep (.clk(clk));                // one level down
endmodule

module v9_top (input logic clk);
  genvar gi;
  generate
    for (gi = 0; gi < 2; gi++) begin : g_loop
      v9_gen_if u_gen (.clk(clk));              // inside a generate loop
    end
  endgenerate
  v9_arr_if u_arr [2] (.clk(clk));              // an interface ARRAY
  v9_child  u_child (.clk(clk));
endmodule
