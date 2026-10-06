// § impPatConcatSelReadParents252
package p;
  typedef enum { E0, E1, E2 } e_t;
  typedef struct packed { integer m0; integer m1; integer m2; integer m3; integer m4; integer m5; integer m6; integer m7; integer m8; integer m9; integer m10; integer m11; } s_t;
  localparam s_t D = '{m0 : 0, m1 : 1, m2 : 2, m3 : 3, m4 : 4, m5 : 5, m6 : 6, m7 : 7, m8 : 8, m9 : 9, m10 : 10, m11 : 11};
  localparam s_t E = '{m0 : 1, m1 : 2, m2 : 3, m3 : 4, m4 : 5, m5 : 6, m6 : 7, m7 : 8, m8 : 9, m9 : 10, m10 : 11, m11 : 12};
  localparam s_t [1:0] ALL = {E, D};
endpackage
module top import p::*; #(parameter Q = 0, localparam s_t P = ALL[Q]) ();
endmodule
