typedef struct packed { logic [31:0] t; } s1_t;
typedef struct packed { logic [7:0] a; logic [15:0] b; logic [7:0] c; } s3_t;
typedef struct packed { int i; } si_t;
typedef struct packed { byte y; logic [23:0] z; } sy_t;
typedef struct packed { bit [11:0] p; bit [3:0] q; } sb_t;
typedef struct packed { logic [31:0] u; } inner_t;
typedef struct packed { inner_t n; logic [7:0] m; } outer_t;

module dm #(
  parameter s1_t   p1 = 32'h4,
  parameter s3_t   p3 = 32'h0A03_0005,
  parameter si_t   pi = 32'd6,
  parameter sy_t   py = 32'h07_000008,
  parameter sb_t   pb = 16'h009A,
  parameter outer_t po = 40'h0000000B_0C
) ();
  logic  m1  [p1.t];          // size-form dim, member = whole struct
  logic  m3a [p3.a];          // FIRST member (MSBs)
  logic  m3b [p3.b];          // MIDDLE member
  logic  m3c [p3.c];          // LAST member
  logic  mi  [pi.i];          // int member
  logic  myy [py.y];          // byte member
  logic  myz [py.z];
  logic  mbp [pb.p];
  logic  mbq [pb.q];
  logic  mon [po.n.u];        // NESTED member
  logic  mom [po.m];
  logic  mr  [p3.b-1:0];      // RANGE-form dim
  logic [p3.b-1:0] mpk;       // PACKED dim
  wire   wn  [p3.a];          // a NET
  logic  mx  [p3.a + 1];      // inside an expression
endmodule
module top; dm u(); endmodule
