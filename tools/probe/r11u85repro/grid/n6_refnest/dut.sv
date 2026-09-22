// r11u85 n6 -- THE FENCE ON THE NESTING RULE: the inner level reached through
// a NAMED localparam instead of a written inner pattern.  Does the producer's
// member stamp restart at the referenced pattern (32) or stay off (64)?
package p;
  typedef struct packed { int unsigned n; logic [7:0] m; } cfg_t;
  typedef struct packed { cfg_t inner; logic [3:0] t; } outer_t;
  localparam cfg_t   INNERLIT = '{n: 13, m: 8'h7C};
  localparam outer_t OUTREF   = '{inner: INNERLIT, t: 4'h3};
  localparam outer_t OUTLIT   = '{inner: '{n: 14, m: 8'h7D}, t: 4'h4};
endpackage

interface ifc #(parameter p::outer_t R = p::OUTREF,
                parameter p::outer_t L = p::OUTLIT) ();
  logic [31:0] f_ref;
  logic [31:0] f_lit;
  logic [31:0] f_reft;
  assign f_ref  = R.inner.n;
  assign f_lit  = L.inner.n;
  assign f_reft = R.t;
endinterface

module dut (output logic [31:0] o);
  ifc u_i ();
  assign o = u_i.f_ref ^ u_i.f_lit ^ u_i.f_reft;
endmodule
