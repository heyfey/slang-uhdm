#!/usr/bin/env python3
import os, shutil
OUT='/tmp/vrgg10_grid7'
if os.path.isdir(OUT): shutil.rmtree(OUT)
os.makedirs(OUT)
SINKS = open('/tmp/vrgg10_grid/f1__portplain/top.sv').read().split('module top;')[0]
TOP = """
module top;
  function automatic logic [7:0] f8(input logic [7:0] a); return a; endfunction
  function automatic logic [7:0] g8(input logic [7:0] a); return a; endfunction
  function automatic logic [7:0] h2(input logic [7:0] a, input logic [7:0] b); return a+b; endfunction
  if (1) begin : g
    localparam bit [7:0] IV = 8'hab;
    %s
  end
endmodule
"""
CELLS = {
 'a_selbare'    : "sink #(8) u (.i_value(f8(IV[3:0])));",
 'b_selcat'     : "sink #(8) u (.i_value(f8({4'h0,IV[3:0]})));",
 'c_selcast'    : "sink #(8) u (.i_value(f8(8'(IV[3:0]))));",
 'd_seladd'     : "sink #(8) u (.i_value(f8(IV[3:0] + 1)));",
 'e_selunary'   : "sink #(8) u (.i_value(f8(~IV[3:0])));",
 'f_selternary' : "sink #(8) u (.i_value(f8(1'b1 ? IV[3:0] : 4'h0)));",
 'g_selrepl'    : "sink #(8) u (.i_value(f8({2{IV[3:0]}})));",
 'h_selarg2'    : "sink #(8) u (.i_value(h2(8'h0, IV[3:0])));",
 'i_selarg2cat' : "sink #(8) u (.i_value(h2(8'h0, {4'h0,IV[3:0]})));",
 'j_syscat'     : "sink #(8) u (.i_value($clog2({4'h0,IV[3:0]})));",
 'k_syscast'    : "sink #(8) u (.i_value($clog2(8'(IV[3:0]))));",
 'l_nestcallcat': "sink #(8) u (.i_value(f8(g8({4'h0,IV[3:0]}))));",
 'm_catcallsel' : "sink #(8) u (.i_value({4'h0, f8(IV[3:0])[3:0]}));",
 'n_barename_incall_cat': "sink #(8) u (.i_value(f8({4'h0,IV[3:0]}))); sink #(8) u2 (.i_value(IV));",
 'o_selcat_and_ca': "wire [7:0] wr; assign wr = IV; sink #(8) u (.i_value(f8({4'h0,IV[3:0]})));",
 'p_castcat'    : "sink #(8) u (.i_value(8'({4'h0,IV[3:0]})));",
 'q_catcat'     : "sink #(8) u (.i_value({4'h0,{4'h0,IV[3:0]}}));",
 'r_ternarycat' : "sink #(8) u (.i_value(1'b1 ? {4'h0,IV[3:0]} : 8'h0));",
 's_callcatnosel': "sink #(8) u (.i_value(f8({4'h0,4'h1})));",
 't_selcatunder2': "sink #(8) u (.i_value(f8({4'h0,{2'h0,IV[1:0]}})));",
}
for n,s in CELLS.items():
    d=os.path.join(OUT,n); os.makedirs(d); open(os.path.join(d,'top.sv'),'w').write(SINKS+TOP%s)
print('cells=%d'%len(CELLS))
