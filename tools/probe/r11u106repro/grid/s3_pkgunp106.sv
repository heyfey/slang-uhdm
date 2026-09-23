// r11u106 grid S3: the struct pattern in a PACKAGE (no instance elaborates
// it), an UNPACKED struct localparam, and a struct PARAMETER port overridden
// by an instance with a pattern.
package r106;
  typedef struct packed { int unsigned XLEN; } cfg_t;
  localparam cfg_t PC = '{XLEN: 32'd24};
  typedef struct packed { logic [PC.XLEN-1:0] x; } pt_t;
  localparam pt_t PL = '{x: 1};
  localparam int PW = 12;
  typedef struct packed { logic [PW-1:0] x; } pw_t;
endpackage
module s3_child #(parameter r106::pw_t CP = '{x: 5}, parameter int N = 6) (input logic i, output logic o);
  typedef struct packed { logic [N-1:0] a; logic [N*2-1:0] b; } nt_t;
  localparam nt_t NL = '{a: 1, b: 2};
  assign o = i ^ CP.x[0] ^ NL.a[0];
endmodule
module s3 #(parameter int W = 10) (input logic i, output logic o1, output logic o2, output logic o3);
  typedef struct { logic [W-1:0] u; int k; } ut_t;
  localparam ut_t c31_unpacked = '{u: 1, k: 2};
  localparam r106::pt_t c32_pkgtype = '{x: 3};
  s3_child u_a (.i(i), .o(o1));
  s3_child #(.CP('{x: 9}), .N(3)) u_b (.i(i), .o(o2));
  s3_child #(.N(W)) u_c (.i(i), .o(o3));
endmodule
