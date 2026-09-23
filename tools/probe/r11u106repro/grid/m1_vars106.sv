// r11u106 grid M1: a variable/net declared with a module-scope TYPEDEF name;
// the elaborated variable's typespec clone and its range bounds.
module m1 #(parameter int unsigned D = 4, parameter int W = 16) (input logic clk, output logic [7:0] q);
  typedef logic [7:0] a01_t [D];
  a01_t v01_size;
  typedef logic [7:0] a02_t [0:D-1];
  a02_t v02_range;
  typedef logic [W-1:0] a03_t;
  a03_t v03_logic;
  typedef logic [W-1:0] a04_t [2];
  a04_t v04_pkdunp;
  typedef logic [7:0] a05_t [D*2];
  a05_t v05_mult;
  typedef a01_t a06_t;
  a06_t v06_alias;
  typedef bit [W-1:0] a07_t;
  a07_t v07_bit;
  typedef logic [1:0][W-1:0] a08_t;
  a08_t v08_packed2d;
  typedef logic [7:0] a09_t [D][2];
  a09_t v09_2unp;
  typedef logic [7:0] a10_t [4];
  a10_t v10_constsz;
  typedef logic [7:0] a11_t [$clog2(W)];
  a11_t v11_clog2;
  typedef logic [7:0] a12_t [D];
  a12_t v12_x, v12_y;
  always_ff @(posedge clk) begin
    v01_size[0] <= 1; v02_range[0] <= 1; v03_logic <= 1; v04_pkdunp[0] <= 1;
    q <= v01_size[1] ^ v02_range[1] ^ v05_mult[0] ^ v06_alias[0] ^ v09_2unp[0][0] ^ v10_constsz[0] ^ v11_clog2[0] ^ v12_x[0] ^ v12_y[0];
  end
endmodule
