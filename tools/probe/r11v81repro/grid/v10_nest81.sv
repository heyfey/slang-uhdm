// r11v81 adversarial arm v10 — NESTED patterns and an UNPACKED struct
// parameter over the same package hops.
package v10p;
  localparam PH = 16'h5;
  localparam PD = 16'd5;
  typedef struct packed { logic [23:0] a; logic [23:0] b; } inner;
  typedef struct packed { logic [23:0] bail; inner i; } outer;
  localparam outer H = '{bail: 8'hxA, i: '{a: PH, b: PD}};
  typedef struct { logic [23:0] u; logic [23:0] v; } uns;
  localparam uns UP = '{u: PH, v: PD};
endpackage
module v10_nest81 #(parameter v10p::outer CH = v10p::H) (output logic [23:0] o);
  localparam v10p::uns LU = v10p::UP;
  assign o = CH.i.a ^ CH.i.b ^ LU.u ^ LU.v;
endmodule
