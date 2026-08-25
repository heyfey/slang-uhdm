// r10v91 arm 2 — TARGET SPELLINGS that slang calls FixedSizeUnpackedArrayType
// but where Surelog may still fill Elem_typespec (=> golden DOES size op0 and
// withholding would be a RIGHT->WRONG regression).
package p2;
  typedef logic [11:0] wd_t;
  typedef struct packed { logic [7:0] a; logic [3:0] b; } sm_t;
  typedef enum logic [11:0] { E0 = 12'd0, E1 = 12'd1 } e_t;
  typedef union packed { logic [11:0] u; logic [11:0] v; } un_t;
  typedef logic [11:0] wa_t [2];
endpackage

interface ifc2;
  logic [11:0] sig;
  logic [11:0] iarr [2];
  modport mp (output iarr, input sig);
endinterface

module v2_targets91 #(parameter int NW = 12, parameter int NH = 2)
  (input logic [11:0] din, output logic [11:0] q, ifc2 itf);
  import p2::*;
  logic [11:0] v12;
  assign v12 = din;

  // 1  inline, parameterised COUNT
  logic [11:0] t1 [NH];        assign t1 = '{v12, din};
  // 2  inline, DESCENDING range
  logic [11:0] t2 [1:0];       assign t2 = '{v12, din};
  // 3  inline, ASCENDING explicit range
  logic [11:0] t3 [0:1];       assign t3 = '{v12, din};
  // 4  typedef'd ELEMENT, inline dim
  wd_t         t4 [2];         assign t4 = '{v12, din};
  // 5  ENUM element
  e_t          t5 [2];         assign t5 = '{e_t'(v12), E1};
  // 6  packed UNION element
  un_t         t6 [2];         assign t6 = '{un_t'(v12), un_t'(din)};
  // 7  packed STRUCT element
  sm_t         t7 [2];         assign t7 = '{sm_t'(v12), sm_t'(din)};
  // 8  packed ARRAY element
  logic [1:0][5:0] t8 [2];     assign t8 = '{v12, din};
  // 9  2-D inline
  logic [11:0] t9 [2][2];      assign t9 = '{'{v12,din},'{din,v12}};
  // 10 parameterised WIDTH
  logic [NW-1:0] t10 [2];      assign t10 = '{v12, din};
  // 11 SIGNED element
  logic signed [11:0] t11 [2]; assign t11 = '{v12, din};
  // 12 1-bit element
  logic        t12 [2];        assign t12 = '{din[0], din[1]};
  // 13 int element (integer_typespec)
  int          t13 [2];        assign t13 = '{int'(v12), 3};
  // 14 TYPEDEF'd unpacked array (MUST KEEP the stamp)
  wa_t         t14;            assign t14 = '{v12, din};
  // 15 SLICE target: assign to a sub-range of an unpacked array
  logic [11:0] t15 [4];        assign t15[0:1] = '{v12, din};
  // 16 ELEMENT target of a 2-D array (target type = 1-D unpacked)
  logic [11:0] t16 [2][2];     assign t16[0] = '{v12, din};
  // 17 an INTERFACE member as the target
  assign itf.iarr = '{v12, din};
  // 18 a single-element inline unpacked array
  logic [11:0] t18 [1];        assign t18 = '{v12};
  // 19 a THREE-element inline unpacked array
  logic [11:0] t19 [3];        assign t19 = '{v12, din, v12};
  // 20 target width != operand width (truncating / extending operands)
  logic [11:0] t20 [2];        assign t20 = '{din[3:0], 20'hFFFFF};
  // 21 a REPLICATED pattern
  logic [11:0] t21 [4];        assign t21 = '{4{v12}};
  // 22 a DEFAULT-keyed pattern
  logic [11:0] t22 [2];        assign t22 = '{default: 12'd7};
  // 23 conditional-op RHS with pattern arms
  logic [11:0] t23 [2];        assign t23 = din[0] ? '{v12, din} : '{din, v12};

  assign q = t1[0]^t2[0]^t3[0]^t4[0]^t5[0]^t6[0].u^{t7[0].a,t7[0].b}^t8[0]^t9[0][0]
           ^ t10[0]^t11[0]^{11'd0,t12[0]}^t13[0][11:0]^t14[0]^t15[0]^t16[0][0]
           ^ t18[0]^t19[0]^t20[0]^t21[0]^t22[0]^t23[0]^itf.sig;
endmodule

module top_v2 (input logic [11:0] din, output logic [11:0] q);
  ifc2 itf();
  assign itf.sig = din;
  v2_targets91 #(.NW(12), .NH(2)) u (.din(din), .q(q), .itf(itf));
endmodule
