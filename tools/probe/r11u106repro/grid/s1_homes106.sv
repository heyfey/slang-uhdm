// r11u106 grid S1: the struct-param member read in a struct member's range,
// one cell per localparam; every cell is a module-scope struct localparam
// initialized by an assignment pattern (the NetlistElaboration road).
package p106;
  typedef struct packed { int unsigned XLEN; int unsigned W2; } cfg_t;
  localparam cfg_t DefaultCfg = '{XLEN: 32'd64, W2: 32'd8};
  typedef struct packed { logic [7:0] a; int unsigned b; } sub_t;
  typedef struct packed { sub_t s; int unsigned N; } ncfg_t;
  localparam ncfg_t NDef = '{s: '{a: 8'd5, b: 32'd6}, N: 32'd12};
endpackage
module s1 #(parameter p106::cfg_t Cfg = p106::DefaultCfg,
            parameter int W = 16,
            parameter p106::ncfg_t NC = p106::NDef)
           (input logic i, output logic [Cfg.XLEN-1:0] o);
  localparam type t01 = struct packed { logic [Cfg.XLEN-1:0] x; };
  localparam t01 c01_lptype = '{x: 1};
  typedef struct packed { logic [Cfg.XLEN-1:0] x; } t02;
  localparam t02 c02_typedef = '{x: 1};
  typedef struct packed { logic [Cfg.W2+1:0] x; } t03;
  localparam t03 c03_plus = '{x: 1};
  typedef struct packed { logic [Cfg.W2*2-1:0] x; } t04;
  localparam t04 c04_mult = '{x: 1};
  typedef struct packed { logic [$clog2(Cfg.XLEN)-1:0] x; } t05;
  localparam t05 c05_clog2 = '{x: 1};
  typedef struct packed { logic [Cfg.W2:0] x; } t06;
  localparam t06 c06_bare = '{x: 1};
  typedef struct packed { logic [W-1:0] x; } t07;
  localparam t07 c07_plainW = '{x: 1};
  typedef struct packed { logic [NC.s.a:0] x; } t08;
  localparam t08 c08_nested = '{x: 1};
  typedef struct packed { logic [Cfg.XLEN-1:Cfg.W2] x; } t09;
  localparam t09 c09_rightnz = '{x: 1};
  typedef struct packed { logic [1:0][Cfg.W2-1:0] x; } t10;
  localparam t10 c10_packed2d = '{x: 1};
  typedef struct packed { t02 inner; logic [W-1:0] y; } t11;
  localparam t11 c11_nestst = '{inner: '{x: 1}, y: 2};
  typedef struct packed { logic [Cfg.XLEN-1:0] x; logic [7:0] z; } t14;
  localparam t14 c14_default = '{default: 0};
  localparam t02 c15_constrhs = 0;
  localparam t02 c16_castrhs = t02'(1);
  typedef struct packed { logic [7:0] x; } t17;
  localparam t17 c17_constbnd = '{x: 1};
  typedef struct packed { bit [Cfg.W2-1:0] x; } t18;
  localparam t18 c18_bit = '{x: 1};
  typedef struct packed { logic [W/2-1:0] x; } t19;
  localparam t19 c19_div = '{x: 1};
  typedef logic [Cfg.W2-1:0] w20_t;
  typedef struct packed { w20_t x; } t20;
  localparam t20 c20_tdmember = '{x: 1};
  assign o = i ? c02_typedef.x : c01_lptype.x;
endmodule
