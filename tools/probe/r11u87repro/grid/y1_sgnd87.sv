// r11u87 arm y1 — THE SIGNED TRUTH TABLE, DECLARED TYPE BY DECLARED TYPE.
// `CompileHelper::valueRange` (CompileHelper.cpp:5548-5583) reads `VpiSigned`
// off int_typespec / logic_typespec / bit_typespec ONLY and calls
// `val->setSigned(...)`; every other typespec kind leaves the store unsigned,
// and `CompileExpression.cpp:3032-3040` mints a bare signed `int_typespec`
// exactly when `sval->isSigned()`.  MODULE-homed hops, 24-bit members,
// operand 0 a guaranteed bail.
package y1p;
  typedef struct packed {
    logic [23:0] bail; logic [23:0] a; logic [23:0] b; logic [23:0] c;
    logic [23:0] d;    logic [23:0] e; logic [23:0] f; logic [23:0] g;
  } t;
  typedef logic signed [15:0] sl_t;
  typedef bit [15:0]          ub_t;
endpackage
module y1_sgnd87;
  localparam int               YIN  = 16'd5;   // int_typespec   signed
  localparam int signed        YIS  = 16'd5;   // int_typespec   signed
  localparam int unsigned      YIU  = 16'd5;   // int_typespec   unsigned
  localparam logic signed [15:0] YLS = 16'd5;  // logic_typespec signed
  localparam logic [15:0]      YLU  = 16'd5;   // logic_typespec unsigned
  localparam bit signed [15:0] YBS  = 16'd5;   // bit_typespec   signed
  localparam bit [15:0]        YBU  = 16'd5;   // bit_typespec   unsigned
  localparam reg signed [15:0] YRS  = 16'd5;   // logic_typespec signed
  localparam signed [15:0]     YSG  = 16'o17;  // int_typespec   signed, octal
  localparam int               YIO  = 16'o17;  // int_typespec   signed, octal
  localparam byte              YBY  = 8'd5;    // byte_typespec  — abstains
  localparam shortint          YSH  = 16'd5;   // short_int      — abstains
  localparam integer           YIG  = 16'd5;   // integer        — abstains
  localparam longint           YLG  = 16'd5;   // long_int       — abstains
  localparam y1p::sl_t         YTD  = 16'd5;   // typedef'd signed logic
  localparam y1p::ub_t         YTU  = 16'd5;   // typedef'd unsigned bit
  localparam y1p::t A = '{bail: 8'hxA, a: YIN, b: YIS, c: YIU, d: YLS,
                          e: YLU, f: YBS, g: YBU};
  localparam y1p::t B = '{bail: 8'hxA, a: YRS, b: YSG, c: YIO, d: YBY,
                          e: YSH, f: YIG, g: YLG};
  localparam y1p::t C = '{bail: 8'hxA, a: YTD, b: YTU, c: YIN, d: YSG,
                          e: YLS, f: YBS, g: YIO};
  y1_sink #(.R(A)) s1();
  y1_sink #(.R(B)) s2();
  y1_sink #(.R(C)) s3();
endmodule
module y1_sink #(parameter y1p::t R = '{default: 0}) (output logic [23:0] o);
  assign o = R.a;
endmodule
