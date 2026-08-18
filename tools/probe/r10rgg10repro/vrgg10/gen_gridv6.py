#!/usr/bin/env python3
import os, sys, shutil
OUT='/tmp/vrgg10_grid6'
if os.path.isdir(OUT): shutil.rmtree(OUT)
os.makedirs(OUT)
SINKS = open('/tmp/vrgg10_grid/f1__portplain/top.sv').read().split('module top;')[0]
TOP = """
module top;
  function automatic logic [7:0] f8(input logic [7:0] a); return a; endfunction
  function automatic logic [7:0] g8(input logic [7:0] a); return a; endfunction
  if (1) begin : g
    localparam bit [7:0] IV = 8'hab;
    %s
  end
endmodule
"""
CELLS = {
 # --- the break and its neighbourhood (function-call argument)
 'callselcat'  : "sink #(8) u (.i_value(f8({4'h0,IV[3:0]})));",
 'callselbare' : "sink #(8) u (.i_value(f8(IV[3:0])));",
 'callselbit'  : "sink #(8) u (.i_value(f8(IV[0])));",
 'callnested'  : "sink #(8) u (.i_value(f8(g8(IV[3:0]))));",
 'callplusout' : "sink #(8) u (.i_value(f8(8'h0) + {4'h0,IV[3:0]}));",
 'callundercast':"sink #(8) u (.i_value(8'(f8(IV[3:0]))));",
 'castundercall':"sink #(8) u (.i_value(f8(8'(IV[3:0]))));",
 'syscallsel'  : "sink #(8) u (.i_value($clog2(IV[3:0])));",
 'syscallbits' : "sink #(8) u (.i_value($bits(IV[3:0])));",
 'syscallsigned':"sink #(8) u (.i_value($signed(IV[3:0])));",
 'callbarename': "sink #(8) u (.i_value(f8(IV)));",
 'callconcat2' : "sink #(8) u (.i_value({f8(8'h0), IV[3:0]}));",
 # --- selects in other wrappers, for the boundary
 'selplain'    : "sink #(8) u (.i_value({4'h0,IV[3:0]}));",
 'selternary'  : "sink #(8) u (.i_value(1'b1 ? {4'h0,IV[3:0]} : 8'h0));",
 'seladd'      : "sink #(8) u (.i_value({4'h0,IV[3:0]} + 1));",
 'selrepl'     : "sink #(8) u (.i_value({2{IV[3:0]}}));",
 'seldouble'   : "sink #(8) u (.i_value({IV[7:4],IV[3:0]}));",
 # --- CA side, for symmetry (pre-existing behaviour, not this patch)
 'cacallsel'   : "wire [7:0] wr; assign wr = f8({4'h0,IV[3:0]});",
 'cacallbare'  : "wire [7:0] wr; assign wr = f8(IV);",
 # --- parameter override with a select (under-fire residue)
 'povsel'      : "sink #(.W(IV[3:0])) u (.i_value(8'h0));",
 'povsel2'     : "sink #(.W({4'h0,IV[3:0]})) u (.i_value(8'h0));",
 'povcall'     : "sink #(.W(f8(IV[3:0]))) u (.i_value(8'h0));",
 # --- both a call-sel AND a plain port read (the patch must still fire)
 'callselplusplain': "sink #(8) u0 (.i_value(f8({4'h0,IV[3:0]}))); sink #(8) u1 (.i_value(IV));",
}
for n, s in CELLS.items():
    d=os.path.join(OUT,n); os.makedirs(d)
    open(os.path.join(d,'top.sv'),'w').write(SINKS + TOP % s)
print('cells=%d'%len(CELLS))
