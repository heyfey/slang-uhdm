// r10v63 — V1: DECLARED TYPE grid against ONE fixed ternary body (the head shape).
// The law claims the FUNCTION BODY decides the encoding and the PARAMETER the
// width.  Every integral declared type slang accepts is a cell here, including
// the shapes the shipped fence text claims are excluded but the CODE lets in
// (packed struct / packed union / typedef'd vector / time / 2-D packed).
// MEASUREMENT ONLY.
function automatic integer vbits(integer value);
  return (value == 1) ? 1 : $clog2(value);
endfunction

typedef logic [11:0] tv12_t;
typedef logic [31:0] ti_t;
typedef bit [7:0]    tb8_t;
typedef struct packed { logic [3:0] a; logic [3:0] b; } sp8_t;
typedef union  packed { logic [7:0] a; bit   [7:0] b; } up8_t;
typedef enum logic [3:0] { E0 = 0, E14 = 14 } en_t;

module s_types #(parameter int Depth = 16384) (output logic o);
  localparam int              c_int      = vbits(Depth);
  localparam int unsigned     c_intu     = vbits(Depth);
  localparam integer          c_integer  = vbits(Depth);
  localparam byte             c_byte     = vbits(Depth);
  localparam byte unsigned    c_byteu    = vbits(Depth);
  localparam shortint         c_short    = vbits(Depth);
  localparam shortint unsigned c_shortu  = vbits(Depth);
  localparam longint          c_long     = vbits(Depth);
  localparam longint unsigned c_longu    = vbits(Depth);
  localparam time             c_time     = vbits(Depth);
  localparam bit              c_bit      = vbits(Depth);
  localparam logic            c_logic    = vbits(Depth);
  localparam reg              c_reg      = vbits(Depth);
  localparam bit [7:0]        c_b8       = vbits(Depth);
  localparam bit signed [7:0] c_b8s      = vbits(Depth);
  localparam logic [31:0]     c_l32      = vbits(Depth);
  localparam logic signed [31:0] c_l32s  = vbits(Depth);
  localparam logic [63:0]     c_l64      = vbits(Depth);
  localparam logic [99:0]     c_l100     = vbits(Depth);
  localparam logic [3:0][7:0] c_l2d      = vbits(Depth);
  localparam tv12_t           c_tv12     = vbits(Depth);
  localparam ti_t             c_ti       = vbits(Depth);
  localparam tb8_t            c_tb8      = vbits(Depth);
  localparam sp8_t            c_sp8      = vbits(Depth);
  localparam up8_t            c_up8      = vbits(Depth);
  localparam en_t             c_en       = en_t'(vbits(Depth));
  localparam                  c_untyped  = vbits(Depth);
  localparam [31:0]           c_ranged   = vbits(Depth);
  assign o = |{c_int[0],c_intu[0],c_integer[0],c_byte[0],c_byteu[0],c_short[0],
               c_shortu[0],c_long[0],c_longu[0],c_time[0],c_bit,c_logic,c_reg,
               c_b8[0],c_b8s[0],c_l32[0],c_l32s[0],c_l64[0],c_l100[0],
               c_l2d[0][0],c_tv12[0],c_ti[0],c_tb8[0],c_sp8.a[0],c_up8.a[0],
               c_en[0],c_untyped[0],c_ranged[0]};
endmodule

module top(output logic o1, output logic o2, output logic o3);
  s_types #(.Depth(16384)) u1 (.o(o1));
  s_types #(.Depth(1))     u2 (.o(o2));
  s_types #(.Depth(300))   u3 (.o(o3));
endmodule
