// r10v63 — V8: EVALUATOR STRESS.  Recursion (bounded and runaway), deep
// nesting, a body whose fold slang can do but Surelog cannot and vice versa,
// automatic vs static lifetime, a function with a static local, a sign-extended
// shift (the SrlgFold arm), and a >64-bit intermediate.  Looking for a CRASH,
// a hang, or a pristine-right -> patched-wrong cell.
// MEASUREMENT ONLY.
function automatic integer f_fact(integer v);
  if (v <= 1) return 1; else return v * f_fact(v - 1);
endfunction
function automatic integer f_deep(integer v);
  return ((((((v - 1) - 1) - 1) - 1) - 1) - 1);
endfunction
function automatic integer f_sext(integer v);
  integer r; r = -8; return r >>> 1;
endfunction
function static integer f_stat(integer v);
  static integer acc = 5; acc = acc + v; return acc;
endfunction
function automatic longint f_wide(longint v);
  return (v * v) - 1;
endfunction
function automatic integer f_shiftbig(integer v);
  return v << 40;
endfunction
function automatic integer f_selfsel(integer v);
  return v[31:16];
endfunction
function automatic integer f_manyret(integer v);
  if (v > 1000) return v - 1;
  if (v > 100)  return v * 2;
  if (v > 10)   return {4'ha, 4'h5};
  return $clog2(v);
endfunction

module s_hard #(parameter int V = 300, parameter longint LV = 64'h1234_5678) (output logic o);
  localparam int      h_fact  = f_fact(6);
  localparam int      h_deep  = f_deep(V);
  localparam int      h_sext  = f_sext(V);
  localparam int      h_stat  = f_stat(V);
  localparam longint  h_wide  = f_wide(LV);
  localparam int      h_shb   = f_shiftbig(V);
  localparam int      h_ssel  = f_selfsel(V);
  localparam int      h_mret  = f_manyret(V);
  localparam bit [7:0] h_mret8 = f_manyret(V);
  localparam logic [23:0] h_deep24 = f_deep(V);
  assign o = |{h_fact[0],h_deep[0],h_sext[0],h_stat[0],h_wide[0],h_shb[0],
               h_ssel[0],h_mret[0],h_mret8[0],h_deep24[0]};
endmodule

module top(output logic o1,output logic o2,output logic o3);
  s_hard #(.V(300))  u1 (.o(o1));
  s_hard #(.V(5))    u2 (.o(o2));
  s_hard #(.V(2000)) u3 (.o(o3));
endmodule
