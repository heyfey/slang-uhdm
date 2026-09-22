// r11u85 n7 -- LAW B with NO interface parameter at all: the nested member is
// read off a PACKAGE localparam, so the interface carries no `param_assign`
// and the fold is what the judge reaches first.
package p;
  typedef struct packed { int unsigned n; logic [7:0] m; } cfg_t;
  typedef struct packed { cfg_t inner; logic [3:0] t; } outer_t;
  localparam cfg_t   LIT = '{n: 6, m: 8'hAA};
  localparam outer_t OUT = '{inner: '{n: 11, m: 8'h5A}, t: 4'h3};
endpackage

interface ifc ();
  logic [31:0] f_flat;
  logic [31:0] f_nest;
  assign f_flat = p::LIT.n;
  assign f_nest = p::OUT.inner.n;
endinterface

module dut (output logic [31:0] o);
  ifc u_i ();
  assign o = u_i.f_flat ^ u_i.f_nest;
endmodule
