#!/usr/bin/env python3
"""grid 2: HOMES x instance counts x views; and the must-stay controls."""
import os
OUT='/tmp/v154_probe/src'
FACES = {'negdec':'-1','negzero':'-0','neglz':'-007','negparen':'-(1)',
         'negneg':'-(-2)','sized':"-32'd3",'unsz':"-'d1",'param':'KM1',
         'submin':'1-2','tilde0':'~0','neg33':'-4294967296','negsep':'-1_0'}
BASES = {'nobase':'', 'bit32':'bit [31:0] ', 'int':'int ', 'byte':'byte '}

def emit(name, body): open(f'{OUT}/{name}.sv','w').write(body)

# --- HOME: $unit ---
for ft,f in FACES.items():
    for bt,b in BASES.items():
        emit(f'q2_unit__{bt}__{ft}', f"""parameter int KM1 = -1;
typedef enum {b}{{ UNIT_MARK = {f}, UNIT_TAIL = 5 }} unit_face_t;
module dut_unit;
  unit_face_t kept;
  initial kept = UNIT_MARK;
endmodule
""")
# --- HOME: module ---
for ft,f in FACES.items():
    for bt,b in BASES.items():
        emit(f'q2_mod__{bt}__{ft}', f"""module dut_mod;
  parameter int KM1 = -1;
  typedef enum {b}{{ MOD_MARK = {f}, MOD_TAIL = 5 }} mod_face_t;
  mod_face_t kept;
  initial kept = MOD_MARK;
endmodule
""")
# --- HOME: class ---
for ft,f in FACES.items():
    for bt,b in BASES.items():
        emit(f'q2_cls__{bt}__{ft}', f"""package clspkg;
  parameter int KM1 = -1;
  class HolderCls;
    typedef enum {b}{{ CLS_MARK = {f}, CLS_TAIL = 5 }} cls_face_t;
    cls_face_t kept;
  endclass
endpackage
module dut_cls; import clspkg::*; HolderCls h; initial h = new(); endmodule
""")
# --- HOME: parameterized class ---
for ft,f in FACES.items():
    for bt,b in BASES.items():
        emit(f'q2_pcls__{bt}__{ft}', f"""package pclspkg;
  parameter int KM1 = -1;
  class ParamHolder #(int WIDE = 8);
    typedef enum {b}{{ PCLS_MARK = {f}, PCLS_TAIL = 5 }} pcls_face_t;
    pcls_face_t kept;
  endclass
endpackage
module dut_pcls; import pclspkg::*; ParamHolder #(16) ph; initial ph = new(); endmodule
""")
# --- HOME: interface ---
for ft,f in FACES.items():
    for bt,b in BASES.items():
        emit(f'q2_ifc__{bt}__{ft}', f"""interface bus_ifc;
  parameter int KM1 = -1;
  typedef enum {b}{{ IFC_MARK = {f}, IFC_TAIL = 5 }} ifc_face_t;
  ifc_face_t kept;
endinterface
module dut_ifc; bus_ifc bi(); endmodule
""")
# --- instance counts 1/2/3 (package home, negdec) ---
for n in (1,2,3):
    insts = '\n'.join(f'  leaf_unit u_leaf{i} ();' for i in range(n))
    emit(f'q3_inst{n}', f"""package instpkg;
  typedef enum bit [31:0] {{ INST_MARK = -1, INST_TAIL = 5 }} inst_face_t;
endpackage
module leaf_unit;
  import instpkg::*;
  inst_face_t held;
  initial held = INST_MARK;
endmodule
module dut_top;
{insts}
endmodule
""")
# --- MUST-STAY: enum used as parameter value / case selector / port default / array index ---
emit('q4_usage', """package usepkg;
  typedef enum bit [31:0] { USE_LOW = -1, USE_MID = 3, USE_HIGH = 7 } use_face_t;
  parameter use_face_t USE_DEFAULT = USE_MID;
endpackage
module consumer #(parameter usepkg::use_face_t PSEL = usepkg::USE_HIGH)
  (input logic clk, output logic [7:0] out_bus);
  import usepkg::*;
  logic [7:0] table_mem [0:7];
  use_face_t chosen;
  always_comb begin
    case (chosen)
      USE_LOW  : out_bus = 8'h01;
      USE_MID  : out_bus = table_mem[USE_MID];
      USE_HIGH : out_bus = table_mem[USE_HIGH];
      default  : out_bus = 8'h00;
    endcase
  end
endmodule
module dut_use;
  logic clk; logic [7:0] ob;
  consumer #(.PSEL(usepkg::USE_LOW)) u_c (.clk(clk), .out_bus(ob));
endmodule
""")
# --- MUST-STAY: uvm_tlm_response_status_e shape (no base, -1..-5) ---
emit('q4_tlmstatus', """package tlmpkg;
  typedef enum { TLM_OK_RESPONSE = 1,
                 TLM_INCOMPLETE_RESPONSE = 0,
                 TLM_GENERIC_ERROR_RESPONSE = -1,
                 TLM_ADDRESS_ERROR_RESPONSE = -2,
                 TLM_COMMAND_ERROR_RESPONSE = -3,
                 TLM_BURST_ERROR_RESPONSE = -4,
                 TLM_BYTE_ENABLE_ERROR_RESPONSE = -5 } tlm_status_e;
  tlm_status_e sig;
endpackage
module dut_tlm; import tlmpkg::*; tlm_status_e s; initial s = TLM_OK_RESPONSE; endmodule
""")
# --- MUST-STAY: implicit successor chains around a negative ---
emit('q4_succ', """package succpkg;
  typedef enum bit [31:0] { SUCC_NEG = -1, SUCC_A, SUCC_B, SUCC_C } succ_face_t;
  typedef enum int { SI_NEG = -5, SI_A, SI_B } succ_int_t;
  typedef enum { SN_NEG = -3, SN_A, SN_B } succ_none_t;
  succ_face_t f; succ_int_t g; succ_none_t h;
endpackage
module dut_succ; import succpkg::*; succ_face_t q; initial q = SUCC_A; endmodule
""")
# --- MUST-STAY: mixed literal encodings other passes own ---
emit('q4_encodings', """package encpkg;
  parameter int PW = 2;
  typedef enum bit [3:0] { EC_BASED = 4'd3, EC_BIN = 4'b0101, EC_HEX = 4'hA,
                           EC_OCT = 4'o7, EC_UNBASED = '0 } enc_face_t;
  typedef enum bit [3:0] { EC_CONCAT = {2'b10, 2'b01}, EC_NEXT } cat_face_t;
  typedef enum int { EC_REF = PW, EC_ARITH = PW + 1, EC_SHIFT = 1 << 3 } ref_face_t;
  enc_face_t a; cat_face_t b; ref_face_t c;
endpackage
module dut_enc; import encpkg::*; enc_face_t z; initial z = EC_BASED; endmodule
""")
# --- overflow of the base width ---
emit('q5_overflow', """package ovfpkg;
  typedef enum byte { OVF_MARK = -200, OVF_NEXT } ovf_face_t;
endpackage
""")
emit('q5_overflow2', """package ovf2pkg;
  typedef enum bit [3:0] { OVF2_MARK = -1, OVF2_NEXT } ovf2_face_t;
  ovf2_face_t s;
endpackage
module dut_ovf2; import ovf2pkg::*; ovf2_face_t z; initial z = OVF2_MARK; endmodule
""")
print('ok')
