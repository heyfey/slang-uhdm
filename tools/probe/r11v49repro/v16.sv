// v11u49 arm v16 — isolate the `time` member: width vs type.
package p;
  typedef struct { logic [7:0] a; logic [63:0] w64; } uw_t;   // 64-bit 4-state vector
  typedef struct { logic [7:0] a; longint l; }      ul_t;     // 64-bit 2-state
  typedef struct { logic [7:0] a; time t; }         ut_t;     // 64-bit time
  typedef struct { logic [7:0] a; realtime rt; }    urt_t;    // realtime (== real)
  localparam uw_t  UW  = '{a:8'd1, w64:64'd5};
  localparam ul_t  UL  = '{a:8'd2, l:64'd6};
  localparam ut_t  UT  = '{a:8'd3, t:64'd7};
  localparam urt_t URT = '{a:8'd4, rt:1.0};
endpackage
module v16 (output logic [31:0] o);
  assign o = p::UW.a + p::UL.a + p::UT.a + p::URT.a;
endmodule
