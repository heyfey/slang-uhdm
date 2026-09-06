// r10earl107 grid arm g1_home107 -- MEASUREMENT ONLY.
// A package parameter whose value is a STRUCT assignment pattern with an
// unsized ('0/'1/'x/'z) member value, connected to a child port.
package pg1_107;
  parameter  W16 = 16;
  parameter  W2  = 2;
  typedef struct packed {
    logic [W16-1:0] a16;
    logic [W2-1:0]  b2;
  } s2_t;
  parameter s2_t S2_DEFAULT = '{
    a16: W16'(1'b1),
    b2: '0
  };
  typedef struct packed {
    logic [7:0] p8;
    logic [3:0] q4;
    logic       r1;
  } s3_t;
  parameter s3_t S3_ONES = '{ p8: '1, q4: '1, r1: '1 };
  parameter s3_t S3_ZERO = '{ p8: '0, q4: '0, r1: '0 };
  parameter s3_t S3_MIX  = '{ p8: 8'hA5, q4: '0, r1: 1'b1 };
endpackage

module child107 (
  input pg1_107::s2_t  c_a,
  input pg1_107::s3_t  c_b,
  input pg1_107::s3_t  c_c,
  input pg1_107::s3_t  c_d
);
  logic unused;
  assign unused = ^{c_a, c_b, c_c, c_d};
endmodule

module g1_home107 (input logic clk, output logic o);
  child107 u_ch (
    .c_a (pg1_107::S2_DEFAULT),
    .c_b (pg1_107::S3_ONES),
    .c_c (pg1_107::S3_ZERO),
    .c_d (pg1_107::S3_MIX)
  );
  assign o = clk;
endmodule
