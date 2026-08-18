package p3;
  function automatic integer pk_clog(integer v); return $clog2(v); endfunction
endpackage
function automatic integer h_cat(integer v);    return {4'ha,4'hb};  endfunction
function automatic integer h_repl(integer v);   return {2{4'ha}};    endfunction
function automatic integer h_cmp(integer v);    return v > 3;        endfunction
function automatic integer h_neg(integer v);    return -v;           endfunction
function automatic integer h_sgn(integer v);    return $signed(v);   endfunction
function automatic integer h_sub(integer v);    return v - 1;        endfunction
function automatic bit [7:0] h_b8cat(int v);    return {4'ha,4'hb};  endfunction
function automatic bit [7:0] h_b8sub(int v);    return v - 1;        endfunction
function automatic logic [15:0] h_l16(int v);   return v;            endfunction
function automatic logic [15:0] h_l16c(int v);  return $clog2(v);    endfunction
function automatic bit [15:0] h_b16c(int v);    return $clog2(v);    endfunction
function automatic integer h_sel(integer v);    return v[7:0];       endfunction

module s3 #(parameter int NB = 300) (output logic o);
  localparam int          t_int_cat   = h_cat(NB);
  localparam int          t_int_repl  = h_repl(NB);
  localparam int          t_int_cmp   = h_cmp(NB);
  localparam int          t_int_neg   = h_neg(NB);
  localparam int          t_int_sgn   = h_sgn(NB);
  localparam int          t_int_sub   = h_sub(NB);
  localparam int          t_int_b8cat = h_b8cat(NB);
  localparam int          t_int_b8sub = h_b8sub(NB);
  localparam int          t_int_l16   = h_l16(NB);
  localparam int          t_int_l16c  = h_l16c(NB);
  localparam int          t_int_b16c  = h_b16c(NB);
  localparam int          t_int_sel   = h_sel(NB);
  localparam int          t_int_pk    = p3::pk_clog(NB);
  localparam bit [7:0]    t_b8_cat    = h_cat(NB);
  localparam bit [7:0]    t_b8_cmp    = h_cmp(NB);
  localparam bit [7:0]    t_b8_neg    = h_neg(NB);
  localparam bit [7:0]    t_b8_sub    = h_sub(NB);
  localparam bit [7:0]    t_b8_l16    = h_l16(NB);
  localparam bit [7:0]    t_b8_sel    = h_sel(NB);
  localparam logic [31:0] t_l32_cat   = h_cat(NB);
  localparam logic [31:0] t_l32_sub   = h_sub(NB);
  localparam logic [31:0] t_l32_l16   = h_l16(NB);
  localparam byte         t_by_cat    = h_cat(NB);
  localparam byte         t_by_cmp    = h_cmp(NB);
  localparam              u_cat       = h_cat(NB);
  localparam              u_cmp       = h_cmp(NB);
  localparam              u_neg       = h_neg(NB);
  localparam              u_sgn       = h_sgn(NB);
  localparam              u_b8cat     = h_b8cat(NB);
  localparam              u_l16       = h_l16(NB);
  localparam              u_b16c      = h_b16c(NB);
  localparam       [31:0] r_clog      = p3::pk_clog(NB);
  localparam       [31:0] r_cat       = h_cat(NB);
  localparam       [31:0] r_neg       = h_neg(NB);
  localparam       [31:0] r_sel       = h_sel(NB);
  assign o = 1'b0;
endmodule
module t3 (output logic o); s3 #(.NB(300)) u3 (.o(o)); endmodule
