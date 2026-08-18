// r10v63 — V7: OVERRIDE STATE.  A `parameter` (overridable) whose DEFAULT is a
// const-call, in the port list and in the body, left defaulted / overridden by
// a literal / overridden by another const-call / overridden by an expression
// over a parent param.  Plus 3 instances so every specialization is present.
// MEASUREMENT ONLY.
function automatic integer vb7(integer value);
  return (value == 1) ? 1 : $clog2(value);
endfunction
function automatic integer sb7(integer value); return value - 1; endfunction

module s_ov #(
  parameter  int          P_TERN = vb7(16384),
  parameter  logic [15:0] P_VT   = vb7(16384),
  parameter  int          P_SUB  = sb7(300),
  parameter  int          P_PLAIN = 7
) (output logic o);
  parameter  int          B_TERN = vb7(16384);
  parameter  logic [15:0] B_VT   = vb7(16384);
  localparam int          L_OF_P = sb7(P_PLAIN);
  assign o = |{P_TERN[0],P_VT[0],P_SUB[0],B_TERN[0],B_VT[0],L_OF_P[0]};
endmodule

module top(output logic o1,output logic o2,output logic o3,output logic o4);
  s_ov                                    u1 (.o(o1));   // all defaulted
  s_ov #(.P_TERN(5), .P_VT(6), .P_SUB(7)) u2 (.o(o2));   // literal overrides
  s_ov #(.P_TERN(vb7(512)), .P_SUB(sb7(9)))u3 (.o(o3));  // const-call overrides
  s_ov #(.P_PLAIN(300))                   u4 (.o(o4));   // parent-driven
endmodule
