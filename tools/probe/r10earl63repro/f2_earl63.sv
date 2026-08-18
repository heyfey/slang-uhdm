// r10earl63 — F2: WHICH FUNCTION-BODY SHAPE makes Surelog's EvalFunc hand back
// an INTEGER Value (INT / vpiConstType 7) rather than an UNSIGNED one (UINT /
// ct 9)?  One localparam per body shape, read in a module BODY, ELAB view.
// MEASUREMENT ONLY.
package p63;
  function automatic integer y_pkgclog(integer v);
    return $clog2(v);
  endfunction
endpackage

function automatic integer a_clog(integer v);   return $clog2(v);              endfunction
function automatic integer b_tern(integer v);   return (v == 1) ? 1 : 2;        endfunction
function automatic integer c_ternc(integer v);  return (v == 1) ? 1 : $clog2(v); endfunction
function automatic integer d_add(integer v);    return v + 1;                   endfunction
function automatic integer e_sub(integer v);    return v - 1;                   endfunction
function automatic integer f_mul(integer v);    return v * 2;                   endfunction
function automatic integer g_div(integer v);    return v / 2;                   endfunction
function automatic integer h_lit(integer v);    return 7;                       endfunction
function automatic integer i_hex(integer v);    return 8'hab;                   endfunction
function automatic integer j_shr(integer v);    return v >> 1;                  endfunction
function automatic integer k_shl(integer v);    return v << 1;                  endfunction
function automatic integer l_bits(integer v);   return $bits(v);                endfunction
function automatic integer m_asgn(integer v);   m_asgn = $clog2(v);             endfunction
function automatic integer n_loop(integer v);
  integer r; r = 0;
  for (int i = 0; i < 4; i++) r = r + 1;
  return r;
endfunction
function automatic integer o_loopc(integer v);
  integer r; r = 0;
  for (int i = 0; i < 4; i++) r = r + 1;
  return $clog2(v);
endfunction
function automatic integer p_nest(integer v);   return a_clog(v);               endfunction
function automatic integer q_uns(integer v);    return $unsigned(v);            endfunction
function automatic integer r_sgn(integer v);    return $signed(v);              endfunction
function automatic integer s_neg(integer v);    return -v;                      endfunction
function automatic integer t_var(integer v);    integer r; r = $clog2(v); return r; endfunction
function automatic integer u_if(integer v);     if (v == 1) return 1; else return $clog2(v); endfunction
function automatic int      v_clogint(int v);   return $clog2(v);               endfunction
function automatic bit [7:0] w_clogbit8(int v); return $clog2(v);               endfunction
function automatic integer x_two(integer v);    return $clog2(v) + 1;           endfunction
function automatic integer z_clogsum(integer v); return $clog2(v) + $clog2(v);  endfunction

module sub63 #(parameter int NB = 16384) (output logic o);
  localparam int i_a_clog    = a_clog(NB);
  localparam int i_b_tern    = b_tern(NB);
  localparam int i_c_ternc   = c_ternc(NB);
  localparam int i_d_add     = d_add(NB);
  localparam int i_e_sub     = e_sub(NB);
  localparam int i_f_mul     = f_mul(NB);
  localparam int i_g_div     = g_div(NB);
  localparam int i_h_lit     = h_lit(NB);
  localparam int i_i_hex     = i_hex(NB);
  localparam int i_j_shr     = j_shr(NB);
  localparam int i_k_shl     = k_shl(NB);
  localparam int i_l_bits    = l_bits(NB);
  localparam int i_m_asgn    = m_asgn(NB);
  localparam int i_n_loop    = n_loop(NB);
  localparam int i_o_loopc   = o_loopc(NB);
  localparam int i_p_nest    = p_nest(NB);
  localparam int i_q_uns     = q_uns(NB);
  localparam int i_r_sgn     = r_sgn(NB);
  localparam int i_s_neg     = s_neg(NB);
  localparam int i_t_var     = t_var(NB);
  localparam int i_u_if      = u_if(NB);
  localparam int i_v_clogint = v_clogint(NB);
  localparam int i_w_clogb8  = w_clogbit8(NB);
  localparam int i_x_two     = x_two(NB);
  localparam int i_y_pkgclog = p63::y_pkgclog(NB);
  localparam int i_z_clogsum = z_clogsum(NB);
  localparam     u_a_clog    = a_clog(NB);
  localparam     u_c_ternc   = c_ternc(NB);
  localparam     u_d_add     = d_add(NB);
  localparam     u_s_neg     = s_neg(NB);
  localparam     u_v_clogint = v_clogint(NB);
  localparam     u_w_clogb8  = w_clogbit8(NB);
  assign o = 1'b0;
endmodule

module top63 (output logic o);
  sub63 #(.NB(16384)) u63 (.o(o));
endmodule
