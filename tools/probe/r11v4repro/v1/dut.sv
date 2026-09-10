// v11u4 ADVERSARIAL v1 — the AGGREGATE face (B) inside the two def flavours
// the RANGE gate exempts: GENERATE-bearing and TEXT-multi.  Does golden clone
// the DECLARATION's op75 onto those port views too, or the connected one?
package p;
  typedef struct packed { int unsigned DAT; } bus_t;
  typedef struct packed { bus_t BUS; } cfg_t;
  localparam cfg_t CDEF = '{BUS: '{DAT: 32}};
  localparam cfg_t COVR = '{BUS: '{DAT: 64}};
endpackage

// GENERATE-bearing def with an aggregate parameter.
interface gif #(parameter p::cfg_t CFG = p::CDEF, parameter int W = 4);
  logic [W-1:0] d;
  generate if (W > 2) begin : gg logic extra; end endgenerate
  modport mp (input d);
endinterface

// plain def with an aggregate parameter, instantiated with two DIFFERENT
// override TEXTS that fold to the same value -> TEXT-multi.
interface tif #(parameter p::cfg_t CFG = p::CDEF, parameter int W = 4);
  logic [W-1:0] d;
  modport mp (input d);
endinterface

module leafg  (gif q);    logic z; assign z = q.d[0]; endmodule
module leafgm (gif.mp q); logic z; assign z = q.d[0]; endmodule
module leaft  (tif q);    logic z; assign z = q.d[0]; endmodule
module leaftm (tif.mp q); logic z; assign z = q.d[0]; endmodule

module top;
  localparam int WW = 9;
  gif #(.CFG(p::COVR), .W(9)) u_g();
  leafg  c0 (.q(u_g));
  leafgm c1 (.q(u_g.mp));
  tif #(p::COVR, 9)      u_t1();
  tif #(.CFG(p::COVR), .W(WW)) u_t2();
  leaft  c2 (.q(u_t1));
  leaft  c3 (u_t2);
  leaftm c4 (.q(u_t1.mp));
endmodule
