// v11u94 break arms: the M law's homes and faces
module b4c #(parameter D = 4) (input logic clk, input logic [7:0] d, output logic [7:0] q);
  typedef logic [7:0] m_t [D];
  m_t mem;
  always_ff @(posedge clk) begin mem[0] <= d; q <= mem[D-1]; end
endmodule
module b4 #(parameter D = 4, parameter int unsigned U = 3, parameter int I = 5)
  (input logic clk, input logic [7:0] d, output logic [7:0] q1, output logic [7:0] q2);
  typedef logic [7:0] a01_t [D+1];
  a01_t v01_plus;
  typedef logic [7:0] a02_t [U];
  a02_t v02_uns;
  typedef logic [7:0] a03_t [I];
  a03_t v03_int;
  typedef logic [7:0] a04_t [0:D+1];
  a04_t v04_expl;
  typedef logic [7:0] a05_t [D+1:0];
  a05_t v05_desc;
  typedef logic [7:0] a06_t [D][U];
  a06_t v06_2d;
  typedef logic a07_t [D<<1];
  a07_t v07_shl;
  typedef logic [3:0][1:0] a08_t [D];
  a08_t v08_pk2;
  typedef logic signed [7:0] a09_t [D];
  a09_t v09_signed;
  typedef logic [7:0] a10_t [D];
  a10_t v10_a, v10_b;
  var a10_t v11_var;
  typedef logic [7:0] a12_t [$clog2(D)];
  a12_t v12_clog2;
  typedef logic [7:0] a13_t [0:D-1];
  a13_t v13_expl2;
  typedef logic [7:0] a14_t [D];
  a14_t v14_init = '{default: 0};
  wire a10_t n16;
  always_ff @(posedge clk) begin v01_plus[0] <= d; v10_a[0] <= d; q1 <= v01_plus[D] ^ v10_a[1]; end
  b4c #(.D(2)) u_a (.clk(clk), .d(d), .q(q2));
  b4c u_b (.clk(clk), .d(d), .q());
endmodule
