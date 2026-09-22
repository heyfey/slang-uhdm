// r11u83 j1 -- LAW B: the interface BODY's own module-level cont_assign.
// Every RHS shape beside the struct-param member read is a control: the
// shapes golden does NOT fold must stay exactly where pristine left them.
package p;
  typedef struct packed { int unsigned n; logic [7:0] m; } cfg_t;
  typedef struct packed { cfg_t inner; logic [3:0] t; } outer_t;
  localparam cfg_t   LIT = '{n: 6, m: 8'hAA};
  localparam outer_t OUT = '{inner: '{n: 11, m: 8'h5A}, t: 4'h3};
  typedef enum logic [1:0] { EA, EB = 2 } e_t;
endpackage

interface ifc #(parameter p::cfg_t C = p::LIT,
                parameter p::outer_t D = p::OUT,
                parameter int W = 5) ();
  logic [31:0] f_mem;    // LAW B: struct-param member read
  logic [31:0] f_wide;   // LAW B: the OTHER member
  logic [31:0] f_nest;   // LAW B: a nested member
  logic [31:0] f_plain;  // CONTROL: a plain int param (a NamedValue)
  logic [31:0] f_const;  // CONTROL: a literal
  logic [31:0] f_enum;   // CONTROL: a package enum const
  logic [31:0] f_own;    // CONTROL: a read of the interface's own net
  logic [31:0] src;
  assign f_mem   = C.n;
  assign f_wide  = C.m;
  assign f_nest  = D.inner.n;
  assign f_plain = W;
  assign f_const = 32'd77;
  assign f_enum  = p::EB;
  assign f_own   = src;
  if (1) begin : gi
    logic [31:0] g_mem;  assign g_mem = C.n;   // the pass-69 gen-scope twin
  end
endinterface

module dut (output logic [31:0] o);
  ifc u_i ();
  assign o = u_i.f_mem ^ u_i.f_wide ^ u_i.f_nest ^ u_i.f_plain ^
             u_i.f_const ^ u_i.f_enum ^ u_i.f_own ^ u_i.gi.g_mem;
endmodule
