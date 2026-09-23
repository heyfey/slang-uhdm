// r11u109 face 3 arms: the evaluator's add / shift / bitwise digits on the pattern op's typespec
package q109;
  typedef struct packed { int unsigned A; logic [7:0] B; int C; } cfg_t;
  localparam cfg_t Cfg0 = '{A: 5, B: 8'd6, C: 32'd7};
  localparam int PK = 9;
endpackage
module f3 #(parameter UW = 16, parameter int IW = 12, parameter int unsigned NW = 10,
            parameter logic [7:0] LW = 8'd4, parameter logic [15:0] HW = 16'h8,
            parameter q109::cfg_t Cfg = q109::Cfg0)
           (input logic i, output logic o);
  localparam int LM = UW * 2;
  localparam LA = UW + 1;
  typedef struct packed { logic [UW+2:0] x; } t01;  localparam t01 a01 = '{x: 1};
  typedef struct packed { logic [2+IW:0] x; } t02;  localparam t02 a02 = '{x: 1};
  typedef struct packed { logic [NW+NW:0] x; } t03; localparam t03 a03 = '{x: 1};
  typedef struct packed { logic [LW+3:0] x; } t04;  localparam t04 a04 = '{x: 1};
  typedef struct packed { logic [HW+1:0] x; } t05;  localparam t05 a05 = '{x: 1};
  typedef struct packed { logic [LM+1:0] x; } t06;  localparam t06 a06 = '{x: 1};
  typedef struct packed { logic [LA+1:0] x; } t07;  localparam t07 a07 = '{x: 1};
  typedef struct packed { logic [UW+8'd1:0] x; } t08; localparam t08 a08 = '{x: 1};
  typedef struct packed { logic [UW+4'hF:0] x; } t09; localparam t09 a09 = '{x: 1};
  typedef struct packed { logic [Cfg.A+1:0] x; } t10; localparam t10 a10 = '{x: 1};
  typedef struct packed { logic [Cfg.B+1:0] x; } t11; localparam t11 a11 = '{x: 1};
  typedef struct packed { logic [Cfg.C+1:0] x; } t12; localparam t12 a12 = '{x: 1};
  typedef struct packed { logic [(UW+1)<<1:0] x; } t13; localparam t13 a13 = '{x: 1};
  typedef struct packed { logic [(UW<<1)+1:0] x; } t14; localparam t14 a14 = '{x: 1};
  typedef struct packed { logic [UW>>>1:0] x; } t15; localparam t15 a15 = '{x: 1};
  typedef struct packed { logic [(UW|IW)-1:0] x; } t16; localparam t16 a16 = '{x: 1};
  typedef struct packed { logic [(UW&24):0] x; } t17; localparam t17 a17 = '{x: 1};
  typedef struct packed { logic [UW^3:0] x; } t18; localparam t18 a18 = '{x: 1};
  typedef struct packed { logic [q109::PK+1:0] x; } t19; localparam t19 a19 = '{x: 1};
  typedef struct packed { logic [3:UW-UW+1] x; } t20; localparam t20 a20 = '{x: 1};
  typedef struct packed { logic [$bits(logic [UW-1:0])-2:0] x; } t21; localparam t21 a21 = '{x: 1};
  typedef struct packed { logic [UW+1:0][IW+1:0] x; } t22; localparam t22 a22 = '{x: 1};
  assign o = i ^ a01.x[0] ^ a13.x[0];
endmodule
module f3top(input logic i, output logic o1, output logic o2);
  f3 #(.UW(20), .IW(3)) u1(.i(i), .o(o1));
  f3 u2(.i(i), .o(o2));
endmodule
