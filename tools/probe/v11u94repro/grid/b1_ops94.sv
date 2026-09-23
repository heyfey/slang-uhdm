// v11u94 break arms: the S law's operator faces (the evaluator's const type per op)
module b1 #(parameter UW = 16, parameter int IW = 16, parameter int unsigned NW = 16,
            parameter logic [7:0] LW = 8'd12)
           (input logic i, output logic o);
  typedef struct packed { logic [UW+1:0] x; } t01;
  localparam t01 c01_uplus = '{x: 1};
  typedef struct packed { logic [IW+1:0] x; } t02;
  localparam t02 c02_iplus = '{x: 1};
  typedef struct packed { logic [NW+1:0] x; } t03;
  localparam t03 c03_nplus = '{x: 1};
  typedef struct packed { logic [(UW>>1)-1:0] x; } t04;
  localparam t04 c04_shsub = '{x: 1};
  typedef struct packed { logic [UW>>1:0] x; } t05;
  localparam t05 c05_shr = '{x: 1};
  typedef struct packed { logic [UW|1:0] x; } t06;
  localparam t06 c06_bor = '{x: 1};
  typedef struct packed { logic [UW&12:0] x; } t07;
  localparam t07 c07_band = '{x: 1};
  typedef struct packed { logic [(UW>4)?7:3:0] x; } t08;
  localparam t08 c08_cond = '{x: 1};
  typedef struct packed { logic [LW+1:0] x; } t09;
  localparam t09 c09_lplus = '{x: 1};
  typedef struct packed { logic [UW+32'd1:0] x; } t10;
  localparam t10 c10_sized = '{x: 1};
  typedef struct packed { logic [1<<2:0] x; } t11;
  localparam t11 c11_shl = '{x: 1};
  typedef struct packed { logic [UW%5:0] x; } t12;
  localparam t12 c12_mod = '{x: 1};
  typedef struct packed { logic [2**3-1:0] x; } t13;
  localparam t13 c13_pow = '{x: 1};
  typedef struct packed { logic [UW+IW:0] x; } t14;
  localparam t14 c14_mix = '{x: 1};
  typedef struct packed { logic [UW:IW-UW] x; } t15;
  localparam t15 c15_zero = '{x: 1};
  assign o = i ^ c01_uplus.x[0] ^ c05_shr.x[0];
endmodule
