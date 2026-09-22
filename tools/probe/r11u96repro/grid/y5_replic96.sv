// r11u96 arm y5 — IS A REPLICATION THE SAME SHAPE AS A CONCATENATION?  y3's
// `NG` says it is not: a SIGNED reader over `int JR = {2{4'd3}}` is golden
// `ts=-` where the same reader over `int JC = {4'd1,4'd2}` is golden `/S`.
// This arm asks the question on its own, both declaration kinds x both reader
// signs x replication / concatenation / a replication inside an operation,
// with the plain-literal controls beside them.
package y5p;
  typedef struct packed {
    logic [23:0] bail; logic [23:0] a; logic [23:0] b; logic [23:0] c;
    logic [23:0] d;    logic [23:0] e; logic [23:0] f; logic [23:0] g;
  } t;
  localparam int           KR   = {2{4'd3}};      // kind 1, replication
  localparam int           KC   = {4'd1, 4'd2};   // kind 1, concatenation
  localparam logic [7:0]   KRU  = {2{4'd3}};      // kind 1 unsigned, replic
  localparam int           KRN  = {2{4'd3}} + 0;  // a replication in an op
  localparam int           KRR  = {{2{2'd1}}, 4'd2};  // nested
  localparam signed        KR2  = {2{4'd3}};      // kind 2, replication
  localparam unsigned      KRU2 = {2{4'd3}};      // kind 2 unsigned, replic
  localparam int           KL   = 8'd51;          // the literal control
  localparam int           KRC  = KR;             // a CHAIN over a replication
  localparam                KRIM = {2{4'd3}};     // kind 0, replication
  localparam int           KCC  = KC;             // a CHAIN over a concat
endpackage
module y5_replic96;
  localparam logic [7:0]         M1 = y5p::KR;
  localparam logic signed [15:0] M2 = y5p::KR;
  localparam logic [7:0]         M3 = y5p::KC;
  localparam logic signed [15:0] M4 = y5p::KC;
  localparam logic [7:0]         M5 = y5p::KRU;
  localparam logic signed [15:0] M6 = y5p::KRU;
  localparam logic [7:0]         M7 = y5p::KRN;
  localparam logic signed [15:0] M8 = y5p::KRN;
  localparam logic [7:0]         M9 = y5p::KRR;
  localparam logic signed [15:0] MA = y5p::KRR;
  localparam logic [7:0]         MB = y5p::KR2;
  localparam logic signed [15:0] MC = y5p::KR2;
  localparam logic signed [15:0] MD = y5p::KRU2;
  localparam logic [7:0]         ME = y5p::KL;
  localparam logic [7:0]         MF = y5p::KRC;
  localparam logic signed [15:0] MG = y5p::KRC;
  localparam logic [7:0]         MH = y5p::KRIM;
  localparam logic signed [15:0] MI = y5p::KRIM;
  localparam logic [7:0]         MJ = y5p::KCC;
  localparam logic signed [15:0] MK = y5p::KCC;
  localparam y5p::t A = '{bail: 8'hxA, a: M1, b: M2, c: M3, d: M4,
                          e: M5, f: M6, g: M7};
  localparam y5p::t B = '{bail: 8'hxA, a: M8, b: M9, c: MA, d: MB,
                          e: MC, f: MD, g: ME};
  localparam y5p::t C = '{bail: 8'hxA, a: MF, b: MG, c: MH, d: MI,
                          e: MJ, f: MK, g: M1};
  y5_sink #(.R(A)) s1();
  y5_sink #(.R(B)) s2();
  y5_sink #(.R(C)) s3();
endmodule
module y5_sink #(parameter y5p::t R = '{default: 0}) (output logic [23:0] o);
  assign o = R.a;
endmodule
