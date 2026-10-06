// § impConcatParamShared262 (the module imports the first package only: control)
package p;
  typedef struct packed { integer a; integer b; } s_t;
  localparam s_t D = '{a : 1, b : 2};
  localparam s_t E = '{a : 3, b : 4};
  parameter s_t [1:0] ALL = {E, D};
endpackage
module top import p::*; (output integer o);
  assign o = 1;
endmodule
