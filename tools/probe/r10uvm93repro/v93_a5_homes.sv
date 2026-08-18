// v93 A5 — the SAME slice size in every home.
package p5;
  typedef logic [7:0] t5;
  function automatic logic [63:0] pf(input logic [63:0] v);
    return { << int { v } };
  endfunction
  task automatic pt(inout logic [63:0] v);
    v = { << byte { v } };
  endtask
endpackage
class C5;
  logic [63:0] m;
  function logic [63:0] inbody(logic [63:0] v);
    return { << int { v } };
  endfunction
  extern function logic [63:0] oob(logic [63:0] v);
  static function logic [63:0] stat(logic [63:0] v);
    return { << longint { v } };
  endfunction
endclass
function logic [63:0] C5::oob(logic [63:0] v);
  return { << shortint { v } };
endfunction
interface I5;
  logic [63:0] v, r;
  always_comb r = { << int { v } };
endinterface
program P5;
  logic [63:0] v, r;
  initial r = { << int { v } };
endprogram
function automatic logic [63:0] unitf(logic [63:0] v);
  return { << bit { v } };
endfunction
module a5_homes;
  logic [63:0] v, r, q, g0, g1;
  I5 i5();
  always_comb q = { << int { v } };
  initial r = { << int { v } };
  function automatic logic [63:0] mf(logic [63:0] x);
    return { << reg { x } };
  endfunction
  generate
    if (1) begin : gb
      logic [63:0] gv, gr;
      always_comb gr = { << int { gv } };
    end
    for (genvar gi = 0; gi < 2; gi++) begin : gl
      logic [63:0] lv, lr;
      always_comb lr = { << byte { lv } };
    end
  endgenerate
  initial begin
    g0 = unitf(v);
    g1 = p5::pf(v);
  end
endmodule
