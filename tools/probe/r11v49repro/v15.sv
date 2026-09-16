// v11u49 arm v15 — more UNPACKED member kinds, all read p::NAME.member:
// chandle / class handle / nested unpacked struct / packed union / unpacked array of struct.
package p;
  typedef struct packed { logic [7:0] x; logic [7:0] y; } inn_t;
  typedef union packed { logic [15:0] w; inn_t s; } pu_t;
  typedef struct { logic [7:0] a; time t; } ut_t;          // `time` is integral
  typedef struct { logic [7:0] a; pu_t u; } upu_t;         // packed union member
  typedef struct { logic [7:0] a; inn_t n; } unest_t;      // packed-struct member
  typedef struct { integer i; logic [7:0] a; } uint_t;     // `integer` is integral
  localparam ut_t    UT  = '{a:8'd1, t:64'd5};
  localparam upu_t   UPU = '{a:8'd2, u:16'h00ff};
  localparam unest_t UNS = '{a:8'd3, n:16'h1234};
  localparam uint_t  UIT = '{i:32'd9, a:8'd4};
endpackage
module v15 (output logic [31:0] o);
  assign o = p::UT.a + p::UPU.a + p::UNS.a + p::UIT.a;
endmodule
