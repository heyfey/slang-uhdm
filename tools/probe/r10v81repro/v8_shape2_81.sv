// r10v81 arm v8 — MORE High_conn ACTUAL SHAPES: a replication, a streaming
// operator, a 2-D packed select, an INOUT port, an assignment-pattern actual,
// and a module parameter that SHADOWS a package parameter of the same name
// (the package fence walks the DECLARING scope, not the reference's).
// MEASUREMENT ONLY.
package ps81;
  parameter int unsigned SHADOW = 9;
endpackage

module leafv8 (input logic ib, input logic [3:0] iv, inout wire iow,
               output logic o);
  assign o = ib ^ (^iv);
endmodule

typedef struct packed { logic [3:0] a; logic [3:0] b; } sv8_t;
module leafs8 (input sv8_t s, output logic o); assign o = ^s; endmodule

module midv8 #(parameter int unsigned N = 1,
               parameter int unsigned SHADOW = 1)   // shadows ps81::SHADOW
              (input logic [15:0] w, inout wire [15:0] iow,
               output logic [15:0] y);
  import ps81::*;
  logic [3:0][3:0] p2;
  leafv8 uRep  (.ib(^{2{w[N]}}),      .iv(w[3:0]), .iow(iow[0]), .o(y[0]));
  leafv8 uP2   (.ib(p2[N][1]),        .iv(w[3:0]), .iow(iow[0]), .o(y[2]));
  leafv8 uIo   (.ib(1'b0),            .iv(w[3:0]), .iow(iow[N]), .o(y[3]));
  leafv8 uShad (.ib(w[SHADOW]),       .iv(w[3:0]), .iow(iow[0]), .o(y[4]));
  leafs8 uPat  (.s('{a: w[N +: 4], b: {3'b0, w[N]}}), .o(y[5]));
  assign p2 = w;
endmodule

module topv8 (input logic [15:0] w, inout wire [15:0] iow,
              output logic [15:0] y);
  midv8 #(.N(2), .SHADOW(3)) i0 (.w(w), .iow(iow), .y(y));
endmodule
