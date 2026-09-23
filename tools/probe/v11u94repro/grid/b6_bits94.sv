// v11u94 break arms: $bits and friends in the bound, both laws
package p96;
  typedef struct packed { logic [3:0] a; logic [2:0] b; } s_t;
endpackage
module b6 #(parameter int W = 8, parameter int unsigned D = 4) (input logic clk, input logic i, output logic o, output logic [7:0] q);
  typedef logic [W-1:0] w_t;
  typedef struct packed { logic [$bits(w_t)-1:0] x; } t01;
  localparam t01 c01_bitstd = '{x: 1};
  typedef struct packed { logic [$bits(p96::s_t)-1:0] x; } t02;
  localparam t02 c02_bitspkg = '{x: 1};
  typedef struct packed { logic [$bits(logic [W-1:0])-1:0] x; } t03;
  localparam t03 c03_bitsanon = '{x: 1};
  typedef struct packed { logic [$size(q)-1:0] x; } t04;
  localparam t04 c04_size = '{x: 1};
  typedef struct packed { logic [$clog2(D+1)-1:0] x; } t05;
  localparam t05 c05_clog2p = '{x: 1};
  typedef struct packed { logic [W-1:0] x; logic [$bits(w_t)*2-1:0] y; } t06;
  localparam t06 c06_bitsmul = '{x: 1, y: 2};
  typedef logic [7:0] a07_t [$bits(w_t)];
  a07_t v07_bits;
  typedef logic [7:0] a08_t [$bits(p96::s_t)];
  a08_t v08_bitspkg;
  typedef logic [7:0] a09_t [$clog2(D)+1];
  a09_t v09_clog;
  typedef logic [7:0] a10_t [W/2];
  a10_t v10_div;
  const a10_t v11_const = '{default: 0};
  typedef logic [7:0] a12_t [$bits(logic [W-1:0])];
  a12_t v12_bitsanon;
  typedef struct packed { logic [$bits(int)-1:0] x; logic [$bits(logic [3:0][1:0])-1:0] y; } t13;
  localparam t13 c13_bitsint = '{x: 1, y: 2};
  always_ff @(posedge clk) begin v07_bits[0] <= 1; q <= v07_bits[1] ^ v08_bitspkg[0] ^ v09_clog[0] ^ v10_div[0] ^ v11_const[0] ^ v12_bitsanon[0]; end
  assign o = i ^ c01_bitstd.x[0];
endmodule
