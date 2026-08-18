// r10v63 — V2: FUNCTION BODY / RETURN-TYPE grid against a fixed `int` target
// plus a `logic [15:0]` target (the type family the shipped branch NEWLY takes
// over from the general arm).  Statement kinds: return / assign / if-else /
// case / for / while / repeat / do-while / foreach / nested-call / local-var.
// MEASUREMENT ONLY.
function automatic integer b_add (integer v); return v + 1;            endfunction
function automatic integer b_sub (integer v); return v - 1;            endfunction
function automatic integer b_mul (integer v); return v * 2;            endfunction
function automatic integer b_div (integer v); return v / 2;            endfunction
function automatic integer b_mod (integer v); return v % 5;            endfunction
function automatic integer b_shl (integer v); return v << 1;           endfunction
function automatic integer b_shr (integer v); return v >> 1;           endfunction
function automatic integer b_ashr(integer v); return v >>> 1;          endfunction
function automatic integer b_and (integer v); return v & 8'hf0;        endfunction
function automatic integer b_or  (integer v); return v | 1;            endfunction
function automatic integer b_xor (integer v); return v ^ 3;            endfunction
function automatic integer b_not (integer v); return ~v;               endfunction
function automatic integer b_lnot(integer v); return !v;               endfunction
function automatic integer b_land(integer v); return v && 1;           endfunction
function automatic integer b_lor (integer v); return v || 0;           endfunction
function automatic integer b_eq  (integer v); return v == 300;         endfunction
function automatic integer b_ne  (integer v); return v != 300;         endfunction
function automatic integer b_lt  (integer v); return v < 300;          endfunction
function automatic integer b_ge  (integer v); return v >= 300;         endfunction
function automatic integer b_tern(integer v); return (v==1) ? 1 : $clog2(v); endfunction
function automatic integer b_cat (integer v); return {4'ha, 4'h5};     endfunction
function automatic integer b_rep (integer v); return {4{2'b10}};       endfunction
function automatic integer b_bsel(integer v); return v[3];             endfunction
function automatic integer b_psel(integer v); return v[7:2];           endfunction
function automatic integer b_isel(integer v); return v[4 +: 5];        endfunction
function automatic integer b_clog(integer v); return $clog2(v);        endfunction
function automatic integer b_bits(integer v); return $bits(v);         endfunction
function automatic integer b_sgn (integer v); return $signed(v);       endfunction
function automatic integer b_uns (integer v); return $unsigned(v);     endfunction
function automatic integer b_neg (integer v); return -v;               endfunction
function automatic integer b_pos (integer v); return +v;               endfunction
function automatic integer b_red (integer v); return |v;               endfunction
function automatic integer b_lit (integer v); return 7;                endfunction
function automatic integer b_hexl(integer v); return 8'hab;            endfunction
function automatic integer b_nest(integer v); return b_clog(v);        endfunction
function automatic integer b_asgn(integer v); b_asgn = v - 1;          endfunction
function automatic integer b_asgc(integer v); b_asgc = {4'ha,4'h5};    endfunction
function automatic integer b_ifel(integer v); if (v > 2) return v - 1; else return v + 1; endfunction
function automatic integer b_case(integer v);
  case (v) 1: return 1; 300: return v - 1; default: return $clog2(v); endcase
endfunction
function automatic integer b_for (integer v);
  integer r; r = 0; for (int i = 0; i < 3; i++) r = r + v; return r;
endfunction
function automatic integer b_whl (integer v);
  integer r; integer i; r = 0; i = 0; while (i < 3) begin r = r + 1; i = i + 1; end return r;
endfunction
function automatic integer b_rep2(integer v);
  integer r; r = 0; repeat (3) r = r + 2; return r;
endfunction
function automatic integer b_do  (integer v);
  integer r; r = 0; do r = r + 1; while (r < 3); return r;
endfunction
function automatic integer b_loc (integer v);
  integer r; r = v - 1; return r;
endfunction
function automatic integer b_two (integer v);
  if (v == 1) b_two = 1; else b_two = v - 1; return b_two;
endfunction

// return types, one body shape (subtract) held constant
function automatic int        r_int  (int v);        return v - 1; endfunction
function automatic bit        r_bit  (int v);        return v - 1; endfunction
function automatic bit [7:0]  r_b8   (int v);        return v - 1; endfunction
function automatic logic[15:0] r_l16 (int v);        return v - 1; endfunction
function automatic byte       r_byte (int v);        return v - 1; endfunction
function automatic shortint   r_shrt (int v);        return v - 1; endfunction
function automatic longint    r_long (int v);        return v - 1; endfunction
function automatic bit signed [7:0] r_b8s(int v);    return v - 1; endfunction

module s_bodies #(parameter int V = 300) (output logic o);
  localparam int i_add=b_add(V);  localparam int i_sub=b_sub(V);
  localparam int i_mul=b_mul(V);  localparam int i_div=b_div(V);
  localparam int i_mod=b_mod(V);  localparam int i_shl=b_shl(V);
  localparam int i_shr=b_shr(V);  localparam int i_ashr=b_ashr(V);
  localparam int i_and=b_and(V);  localparam int i_or=b_or(V);
  localparam int i_xor=b_xor(V);  localparam int i_not=b_not(V);
  localparam int i_lnot=b_lnot(V);localparam int i_land=b_land(V);
  localparam int i_lor=b_lor(V);  localparam int i_eq=b_eq(V);
  localparam int i_ne=b_ne(V);    localparam int i_lt=b_lt(V);
  localparam int i_ge=b_ge(V);    localparam int i_tern=b_tern(V);
  localparam int i_cat=b_cat(V);  localparam int i_rep=b_rep(V);
  localparam int i_bsel=b_bsel(V);localparam int i_psel=b_psel(V);
  localparam int i_isel=b_isel(V);localparam int i_clog=b_clog(V);
  localparam int i_bits=b_bits(V);localparam int i_sgn=b_sgn(V);
  localparam int i_uns=b_uns(V);  localparam int i_neg=b_neg(V);
  localparam int i_pos=b_pos(V);  localparam int i_red=b_red(V);
  localparam int i_lit=b_lit(V);  localparam int i_hexl=b_hexl(V);
  localparam int i_nest=b_nest(V);localparam int i_asgn=b_asgn(V);
  localparam int i_asgc=b_asgc(V);localparam int i_ifel=b_ifel(V);
  localparam int i_case=b_case(V);localparam int i_for=b_for(V);
  localparam int i_whl=b_whl(V);  localparam int i_rp2=b_rep2(V);
  localparam int i_do=b_do(V);    localparam int i_loc=b_loc(V);
  localparam int i_two=b_two(V);
  localparam int i_rint=r_int(V); localparam int i_rbit=r_bit(V);
  localparam int i_rb8=r_b8(V);   localparam int i_rl16=r_l16(V);
  localparam int i_rbyt=r_byte(V);localparam int i_rsht=r_shrt(V);
  localparam int i_rlng=r_long(V);localparam int i_rb8s=r_b8s(V);
  // the family the branch NEWLY takes over from the general arm
  localparam logic [15:0] v_sub=b_sub(V);  localparam logic [15:0] v_cat=b_cat(V);
  localparam logic [15:0] v_rep=b_rep(V);  localparam logic [15:0] v_eq=b_eq(V);
  localparam logic [15:0] v_tern=b_tern(V);localparam logic [15:0] v_clog=b_clog(V);
  localparam logic [15:0] v_sgn=b_sgn(V);  localparam logic [15:0] v_neg=b_neg(V);
  localparam logic [15:0] v_psel=b_psel(V);localparam logic [15:0] v_not=b_not(V);
  localparam bit [7:0]    w_sub=b_sub(V);  localparam bit [7:0] w_cat=b_cat(V);
  localparam bit [7:0]    w_tern=b_tern(V);localparam bit [7:0] w_neg=b_neg(V);
  assign o = |{i_add[0],i_sub[0],i_mul[0],i_div[0],i_mod[0],i_shl[0],i_shr[0],
     i_ashr[0],i_and[0],i_or[0],i_xor[0],i_not[0],i_lnot[0],i_land[0],i_lor[0],
     i_eq[0],i_ne[0],i_lt[0],i_ge[0],i_tern[0],i_cat[0],i_rep[0],i_bsel[0],
     i_psel[0],i_isel[0],i_clog[0],i_bits[0],i_sgn[0],i_uns[0],i_neg[0],
     i_pos[0],i_red[0],i_lit[0],i_hexl[0],i_nest[0],i_asgn[0],i_asgc[0],
     i_ifel[0],i_case[0],i_for[0],i_whl[0],i_rp2[0],i_do[0],i_loc[0],i_two[0],
     i_rint[0],i_rbit[0],i_rb8[0],i_rl16[0],i_rbyt[0],i_rsht[0],i_rlng[0],
     i_rb8s[0],v_sub[0],v_cat[0],v_rep[0],v_eq[0],v_tern[0],v_clog[0],v_sgn[0],
     v_neg[0],v_psel[0],v_not[0],w_sub[0],w_cat[0],w_tern[0],w_neg[0]};
endmodule

module top(output logic o1, output logic o2, output logic o3);
  s_bodies #(.V(300)) u1 (.o(o1));
  s_bodies #(.V(1))   u2 (.o(o2));
  s_bodies #(.V(64))  u3 (.o(o3));
endmodule
