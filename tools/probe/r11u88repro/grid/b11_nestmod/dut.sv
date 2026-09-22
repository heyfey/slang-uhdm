// v11u83 b11 -- the MODULE twin of j1_ifcafold's f_nest cell: does the module
// home fold a NESTED struct-param member read to golden's vpiSize, or does it
// carry the same 32-vs-64 reading the interface home now shows?
package p;
  typedef struct packed { int unsigned n; logic [7:0] m; } cfg_t;
  typedef struct packed { cfg_t inner; logic [3:0] t; } outer_t;
  localparam cfg_t   LIT = '{n: 6, m: 8'hAA};
  localparam outer_t OUT = '{inner: '{n: 11, m: 8'h5A}, t: 4'h3};
endpackage

module sub #(parameter p::cfg_t C = p::LIT,
             parameter p::outer_t D = p::OUT) (output logic [31:0] o);
  logic [31:0] f_mem;
  logic [31:0] f_nest;
  assign f_mem  = C.n;
  assign f_nest = D.inner.n;
  assign o = f_mem ^ f_nest;
endmodule

module dut (output logic [31:0] o);
  sub u_s (.o(o));
endmodule
