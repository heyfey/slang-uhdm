// r10v95 -- adversarial arm C: every elaborated select FACE, at gen depth 1
// (golden folds) and gen depth 2 (golden keeps the ref), three instantiations.
package p95v;
  parameter int PKGW = 4;
endpackage

module faces95 #(parameter int W = 8) (
  input  logic [31:0] din,
  output logic [7:0]  o1, o2, o3, o4, o5, o6, o7, o8, o9, o10,
  output logic [7:0]  q1, q2, q3, q4, q5, q6, q7, q8, q9, q10
);
  import p95v::*;
  localparam int LP  = 3;
  localparam int OFF = 1;
  localparam logic [167:0] W168 [0:3] = '{168'd1, 168'd2, 168'd3, 168'd4};
  localparam logic [63:0]  W64  [0:3] = '{64'd1, 64'd2, 64'd3, 64'd4};
  localparam logic [31:0]  W32  [0:3] = '{32'd1, 32'd2, 32'd3, 32'd4};
  localparam logic [7:0]   W8   [0:3] = '{8'd1, 8'd2, 8'd3, 8'd4};
  localparam int           INTS [0:3] = '{1, 2, 3, 4};
  localparam logic [31:0]  PVEC = 32'hdead_beef;

  typedef struct packed { logic [7:0] a; logic [7:0] b; } st95_t;

  logic [31:0] nvec;
  st95_t [3:0] sarr;
  logic [3:0][7:0] two_d;
  logic [31:0] vvar;

  assign nvec = din;
  assign sarr = {din, din};
  assign two_d = din;
  always_comb vvar = din;

  function automatic int fsel95(input int x);
    return x - 1;
  endfunction

  // ---------------- depth 1: golden FOLDS (distance 1) ----------------
  if (W > 0) begin : d1
    assign o1  = W168[LP-OFF][7:0];        // wide array, param-op-param index
    assign o2  = W64[LP][7:0] | PVEC[LP+4:LP-3]; // bare param index + packed-param part-select
    assign o3  = W32[1][W-8+7 : W-8];      // literal index, param part-select bounds
    assign o4  = W8[INTS[LP-2]] ^ W8[fsel95(LP)]; // NESTED select index + CALL index
    assign o5  = nvec[LP+4 -: LP+1];       // ips BASE param-op and WIDTH param
    assign o6  = {{(LP){din[0]}}, din[4:0]}; // replication count + concat element
    assign o7  = nvec[LP+4 : LP-3];        // net, both part-select bounds
    assign o8  = vvar[LP+4 : LP-3];        // variable
    assign o9  = sarr[LP-2].a;             // struct array
    assign o10 = two_d[LP-2][7:0];         // 2-D array
  end
  // ---------------- depth 2: golden KEEPS the ref (distance 2) --------
  if (W > 0) begin : e1
    if (W > 0) begin : e2
      assign q1  = W168[LP-OFF][7:0];
      assign q2  = W64[LP][7:0] | PVEC[LP+4:LP-3];
      assign q3  = W32[1][W-8+7 : W-8];
      assign q4  = W8[INTS[LP-2]] ^ W8[fsel95(LP)];
      assign q5  = nvec[LP+4 -: LP+1];
      assign q6  = {{(LP){din[0]}}, din[4:0]};
      assign q7  = nvec[LP+4 : LP-3];
      assign q8  = vvar[LP+4 : LP-3];
      assign q9  = sarr[LP-2].a;
      assign q10 = two_d[LP-2][7:0];
    end
  end
endmodule

module v95c_faces (input logic [31:0] din,
                   output logic [7:0] a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,
                   output logic [7:0] b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,
                   output logic [7:0] c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,
                   output logic [7:0] d1_,d2_,d3_,d4_,d5_,d6_,d7_,d8_,d9_,d10_,
                   output logic [7:0] e1_,e2_,e3_,e4_,e5_,e6_,e7_,e8_,e9_,e10_,
                   output logic [7:0] f1_,f2_,f3_,f4_,f5_,f6_,f7_,f8_,f9_,f10_);
  faces95 #(.W(8))  u8  (.din(din), .o1(a1),.o2(a2),.o3(a3),.o4(a4),.o5(a5),.o6(a6),.o7(a7),.o8(a8),.o9(a9),.o10(a10),
                                    .q1(b1),.q2(b2),.q3(b3),.q4(b4),.q5(b5),.q6(b6),.q7(b7),.q8(b8),.q9(b9),.q10(b10));
  faces95 #(.W(16)) u16 (.din(din), .o1(c1),.o2(c2),.o3(c3),.o4(c4),.o5(c5),.o6(c6),.o7(c7),.o8(c8),.o9(c9),.o10(c10),
                                    .q1(d1_),.q2(d2_),.q3(d3_),.q4(d4_),.q5(d5_),.q6(d6_),.q7(d7_),.q8(d8_),.q9(d9_),.q10(d10_));
  faces95 #(.W(32)) u32 (.din(din), .o1(e1_),.o2(e2_),.o3(e3_),.o4(e4_),.o5(e5_),.o6(e6_),.o7(e7_),.o8(e8_),.o9(e9_),.o10(e10_),
                                    .q1(f1_),.q2(f2_),.q3(f3_),.q4(f4_),.q5(f5_),.q6(f6_),.q7(f7_),.q8(f8_),.q9(f9_),.q10(f10_));
endmodule
