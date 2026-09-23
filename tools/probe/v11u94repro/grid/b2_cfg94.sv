// v11u94 break arms: the struct-parameter member read with each operator; member types vary
package p94;
  typedef struct packed { int unsigned XLEN; int W2; logic [7:0] B; bit EN; } cfg_t;
  localparam cfg_t DefCfg = '{XLEN: 32'd64, W2: 8, B: 8'd4, EN: 1'b1};
endpackage
module b2 #(parameter p94::cfg_t Cfg = p94::DefCfg) (input logic i, output logic o);
  typedef struct packed { logic [Cfg.XLEN+1:0] x; } t01;
  localparam t01 c01_xplus = '{x: 1};
  typedef struct packed { logic [Cfg.W2+1:0] x; } t02;
  localparam t02 c02_wplus = '{x: 1};
  typedef struct packed { logic [Cfg.B+1:0] x; } t03;
  localparam t03 c03_bplus = '{x: 1};
  typedef struct packed { logic [Cfg.XLEN>>1:0] x; } t04;
  localparam t04 c04_shr = '{x: 1};
  typedef struct packed { logic [Cfg.EN?7:3:0] x; } t05;
  localparam t05 c05_cond = '{x: 1};
  typedef struct packed { logic [Cfg.XLEN/8+Cfg.B:0] x; } t06;
  localparam t06 c06_divplus = '{x: 1};
  typedef struct packed { logic [Cfg.B-1:0] x; logic [Cfg.XLEN-1:0] y; } t07;
  localparam t07 c07_lsub = '{x: 1, y: 2};
  typedef struct packed { logic signed [Cfg.W2-1:0] x; } t08;
  localparam t08 c08_signed = '{x: 1};
  typedef struct packed { logic [Cfg.XLEN-1:0][Cfg.B-1:0] x; } t09;
  localparam t09 c09_2d = '{x: 1};
  typedef struct packed { logic [Cfg.XLEN|1:0] x; } t10;
  localparam t10 c10_bor = '{x: 1};
  assign o = i ^ c01_xplus.x[0];
endmodule
