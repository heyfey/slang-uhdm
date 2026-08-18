function automatic integer k_sub(integer v);  return v - 1;      endfunction
function automatic integer k_mul(integer v);  return v * 2;      endfunction
function automatic integer k_add(integer v);  return v + 1;      endfunction
function automatic integer k_neg(integer v);  return -v;         endfunction
function automatic integer k_not(integer v);  return ~v;         endfunction
function automatic integer k_sgn(integer v);  return $signed(v); endfunction
function automatic integer k_uns(integer v);  return $unsigned(v); endfunction
function automatic integer k_rep(integer v);  return {2{4'ha}};  endfunction
function automatic integer k_rep8(integer v); return {8{1'b1}};  endfunction
function automatic integer k_cat(integer v);  return {4'h5,4'h5}; endfunction
function automatic integer k_and(integer v);  return v && 1;     endfunction
function automatic integer k_lor(integer v);  return v | 1;      endfunction
function automatic int     k_isub(int v);     return v - 1;      endfunction
function automatic bit [7:0] k_b8sgn(int v);  return $signed(v); endfunction
module s4 #(parameter int NB = 300) (output logic o);
  localparam              u_sub  = k_sub(NB);
  localparam              u_mul  = k_mul(NB);
  localparam              u_add  = k_add(NB);
  localparam              u_neg  = k_neg(NB);
  localparam              u_not  = k_not(NB);
  localparam              u_sgn  = k_sgn(NB);
  localparam              u_uns  = k_uns(NB);
  localparam              u_rep  = k_rep(NB);
  localparam              u_rep8 = k_rep8(NB);
  localparam              u_cat  = k_cat(NB);
  localparam              u_and  = k_and(NB);
  localparam              u_lor  = k_lor(NB);
  localparam              u_isub = k_isub(NB);
  localparam              u_b8s  = k_b8sgn(NB);
  localparam int          i_sub  = k_sub(NB);
  localparam int          i_not  = k_not(NB);
  localparam int          i_sgn  = k_sgn(NB);
  localparam int          i_uns  = k_uns(NB);
  localparam int          i_rep  = k_rep(NB);
  localparam int          i_rep8 = k_rep8(NB);
  localparam int          i_cat  = k_cat(NB);
  localparam int          i_and  = k_and(NB);
  localparam int          i_lor  = k_lor(NB);
  localparam int          i_isub = k_isub(NB);
  localparam byte         b_rep  = k_rep(NB);
  localparam byte         b_rep8 = k_rep8(NB);
  localparam byte         b_cat  = k_cat(NB);
  localparam bit [7:0]    v8_rep = k_rep(NB);
  localparam bit [7:0]    v8_cat = k_cat(NB);
  localparam logic [31:0] l_rep  = k_rep(NB);
  localparam logic [3:0]  n4_rep = k_rep(NB);
  localparam logic [3:0]  n4_cat = k_cat(NB);
  localparam       [3:0]  r4_rep = k_rep(NB);
  localparam       [3:0]  r4_cat = k_cat(NB);
  assign o = 1'b0;
endmodule
module t4 (output logic o); s4 #(.NB(300)) u4 (.o(o)); endmodule
