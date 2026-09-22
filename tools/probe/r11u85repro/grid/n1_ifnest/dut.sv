// r11u85 n1 -- LAW B: the interface home's WIDTH answer.  A NESTED
// struct-parameter member read x three Lhs widths, beside the FLAT read at the
// same three widths.  If golden's answer moves with the Lhs the home binds;
// if it is constant the home does not.
package p;
  typedef struct packed { int unsigned n; logic [7:0] m; } cfg_t;
  typedef struct packed { cfg_t inner; logic [3:0] t; } outer_t;
  typedef struct packed { outer_t o2; logic [1:0] u; } outer2_t;
  localparam cfg_t    LIT  = '{n: 6, m: 8'hAA};
  localparam outer_t  OUT  = '{inner: '{n: 11, m: 8'h5A}, t: 4'h3};
  localparam outer2_t OUT2 = '{o2: '{inner: '{n: 21, m: 8'h11}, t: 4'h2}, u: 2'h1};
endpackage

interface ifc #(parameter p::cfg_t    C = p::LIT,
                parameter p::outer_t  D = p::OUT,
                parameter p::outer2_t E = p::OUT2) ();
  logic [31:0] f_flat;
  logic  [7:0] f_flat8;
  logic [63:0] f_flat64;
  logic [31:0] f_nest;
  logic  [7:0] f_nest8;
  logic [63:0] f_nest64;
  logic [31:0] f_nestm;
  logic [31:0] f_nest3;
  logic [31:0] f_nestt;
  assign f_flat   = C.n;
  assign f_flat8  = C.n;
  assign f_flat64 = C.n;
  assign f_nest   = D.inner.n;
  assign f_nest8  = D.inner.n;
  assign f_nest64 = D.inner.n;
  assign f_nestm  = D.inner.m;
  assign f_nest3  = E.o2.inner.n;
  assign f_nestt  = E.o2.t;
endinterface

module dut (output logic [31:0] o);
  ifc u_i ();
  assign o = u_i.f_flat ^ {24'd0, u_i.f_flat8} ^ u_i.f_flat64[31:0] ^
             u_i.f_nest ^ {24'd0, u_i.f_nest8} ^ u_i.f_nest64[31:0] ^
             u_i.f_nestm ^ u_i.f_nest3 ^ u_i.f_nestt;
endmodule
