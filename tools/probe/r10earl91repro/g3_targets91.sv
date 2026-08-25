// r10earl91 g3 — THE TARGET-DECLARATION GRID.  Surelog's `adjustOpSize`
// (CompileHelper.cpp:4990) dispatches on the ASSIGN TARGET's typespec kind:
// `uhdmarray_typespec` is the ONE branch that can leave `cop->VpiSize()`
// untouched, because it only writes a size when `Elem_typespec()` is non-null.
// Surelog CAN fill that ref (ElaborationStep.cpp:211, UhdmWriter.cpp:752/3195),
// so every unpacked-array SPELLING has to be measured, not assumed.
package r91;
  typedef struct packed { logic [11:0] q; } p_t;
  typedef struct packed { p_t prescale; logic [7:0] s; } c_t;
  typedef struct packed { c_t cfg0; logic ctrl; } rr_t;
  typedef logic [11:0]  w_t;
  typedef w_t           wa_t [2];      // a typedef'd UNPACKED ARRAY
  typedef struct packed { logic [3:0] a; logic [3:0] b; } sm_t;
endpackage

interface if91;
  import r91::*;
  rr_t reg2hw;
endinterface

module g3_targets91 (input logic clk, output logic [63:0] o);
  import r91::*;
  localparam int NH = 1;
  localparam int NW = 12;
  rr_t reg2hw;
  if91 u_if ();

  // T1  logic [11:0] x [NH]        — THE HEAD'S OWN SHAPE (parameterised dim)
  logic [11:0] t1 [NH];   assign t1 = '{reg2hw.cfg0.prescale.q};
  // T2  an explicit ascending unpacked range
  logic [11:0] t2 [0:0];  assign t2 = '{reg2hw.cfg0.prescale.q};
  // T3  an explicit DESCENDING unpacked range, two rows
  logic [11:0] t3 [1:0];  assign t3 = '{reg2hw.cfg0.prescale.q, 12'd1};
  // T4  a two-row ascending unpacked array
  logic [11:0] t4 [2];    assign t4 = '{reg2hw.cfg0.prescale.q, 12'd1};
  // T5  a SCALAR element
  logic        t5 [2];    assign t5 = '{reg2hw.ctrl, 1'b0};
  // T6  a PARAMETERISED element width
  logic [NW-1:0] t6 [1];  assign t6 = '{reg2hw.cfg0.prescale.q};
  // T7  a TYPEDEF'd element type
  w_t          t7 [1];    assign t7 = '{reg2hw.cfg0.prescale.q};
  // T8  a TYPEDEF'd UNPACKED ARRAY type
  wa_t         t8;        assign t8 = '{reg2hw.cfg0.prescale.q, 12'd2};
  // T9  an unpacked array of a PACKED STRUCT
  sm_t         t9 [1];    assign t9 = '{'{reg2hw.cfg0.prescale.q[3:0], 4'h1}};
  // T10 a TWO-DIMENSIONAL unpacked array
  logic [11:0] ta [1][1]; assign ta = '{'{reg2hw.cfg0.prescale.q}};
  // T11 an unpacked array of a PACKED ARRAY element
  logic [1:0][5:0] tb [1]; assign tb = '{reg2hw.cfg0.prescale.q};
  // T12 the root is an INTERFACE member
  logic [11:0] tc [1];    assign tc = '{u_if.reg2hw.cfg0.prescale.q};
  // T13 an unpacked array VARIABLE (not a net)
  logic [11:0] td [1];
  always_comb td = '{reg2hw.cfg0.prescale.q};
  // T14 the pattern is the source of a PORT connection (unpacked formal)
  // (left out on purpose: an unpacked formal port is a different producer)

  assign o = {4'd0, t1[0], t2[0], t3[0], t3[1], t4[0]} ^
             {51'd0, t5[0], t5[1], t6[0]} ^
             {28'd0, t7[0], t8[0], t8[1]} ^
             {48'd0, t9[0].a, t9[0].b, ta[0][0]} ^
             {40'd0, tb[0], tc[0]} ^
             {52'd0, td[0]};
endmodule
