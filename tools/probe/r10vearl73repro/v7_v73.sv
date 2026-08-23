// r10v73 v7 — X/Z operands, system functions, class/interface params, real
// arithmetic into integral formals, self-size folds.  MEASUREMENT ONLY.
module ch7 #(parameter int P = 7) (); localparam int U = 1; endmodule
module ch7b #(parameter bit [7:0] P = 7) (); localparam int U = 1; endmodule
module topv7;
  parameter int A = 256;
  parameter int B = 2;
  parameter logic [7:0] XV = 8'hxA;
  parameter logic [7:0] ZV = 8'hz1;
  parameter real R = 5.0;
  localparam logic [7:0] ARR8 [4] = '{1,2,3,4};
  // X/Z operands into arithmetic
  ch7  #(.P(XV * 2))     u_x1 ();
  ch7  #(.P(XV - 1))     u_x2 ();
  ch7  #(.P(ZV / 2))     u_z1 ();
  ch7b #(.P(XV + 1))     u_x3 ();
  // system functions
  ch7 #(.P($size(ARR8)))       u_sz  ();
  ch7 #(.P($high(ARR8)))       u_hi  ();
  ch7 #(.P($low(ARR8)))        u_lo  ();
  ch7 #(.P($bits(XV) * 2))     u_bt  ();
  ch7 #(.P($clog2(A) - 1))     u_cl  ();
  ch7 #(.P($size(ARR8) * 2))   u_sz2 ();
  // real arithmetic into an integral formal
  ch7 #(.P(int'(R * 2.0)))     u_r1  ();
  ch7 #(.P($rtoi(R - 1.0)))    u_r2  ();
  // element select of an unpacked param into arithmetic
  ch7 #(.P(ARR8[2] * 3))       u_es  ();
  // part select / bit select into arithmetic
  ch7 #(.P(A[7:0] + 1))        u_ps  ();
  ch7 #(.P(A[8] * 4))          u_bs  ();
  // a self-referential-ish chain and a modulo by a parameter
  localparam int M = A % (B + 1);
  ch7 #(.P(M * M))             u_mm  ();
  // signed literal arithmetic
  ch7 #(.P(8'sh80 * 2))        u_sl  ();
  ch7 #(.P(-8'sh80))           u_sn  ();
endmodule
