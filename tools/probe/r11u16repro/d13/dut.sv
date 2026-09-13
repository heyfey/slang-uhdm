// d13 — WHICH BUILDER SHAPES REACH THE ASSEMBLED CONSTANT.  d6 measured that a
// struct with a NESTED STRUCT member written by a pattern leaves golden's
// elaborated param_assign Rhs a `struct_var` (the assembler bailed) while the
// member reads still fold — through the LEFTOVER arm, in a DIFFERENT encoding.
// Each module here varies ONE thing so the bail's cause is named, not guessed.
package p;
  typedef struct packed { int unsigned w; logic [7:0] t; } inner_t;
  typedef enum logic [3:0] { E0 = 4'd0, E1 = 4'd1 } e_t;

  typedef struct packed { int unsigned n; inner_t u; } nest_t;   // nested struct
  typedef struct packed { int unsigned n; logic [2:0][15:0] arr; } arr_t;
  typedef struct packed { int unsigned n; e_t e; } enum_t;
  typedef struct packed { int unsigned n; logic [7:0] t; } flat_t;

  function automatic nest_t bnest_pat();
    nest_t r;  r.n = 4;  r.u = '{w: 9, t: 8'hA5};  return r;
  endfunction
  function automatic nest_t bnest_mem();
    nest_t r;  r.n = 4;  r.u.w = 9;  r.u.t = 8'hA5;  return r;
  endfunction
  function automatic arr_t barr();
    arr_t r;   r.n = 5;  r.arr = {16'h1111, 16'h2222, 16'h3333};  return r;
  endfunction
  function automatic enum_t benum();
    enum_t r;  r.n = 6;  r.e = E1;  return r;
  endfunction
  function automatic flat_t bflat();
    flat_t r;  r.n = 7;  r.t = 8'hA5;  return r;
  endfunction
endpackage

module m_nest_pat #(parameter p::nest_t C = p::bnest_pat()) (output logic [31:0] o, output logic [31:0] o2);
  assign o = C.n;  assign o2 = C.u.w;
endmodule
module m_nest_mem #(parameter p::nest_t C = p::bnest_mem()) (output logic [31:0] o, output logic [31:0] o2);
  assign o = C.n;  assign o2 = C.u.w;
endmodule
module m_arr #(parameter p::arr_t C = p::barr()) (output logic [31:0] o, output logic [47:0] o2);
  assign o = C.n;  assign o2 = C.arr;
endmodule
module m_enum #(parameter p::enum_t C = p::benum()) (output logic [31:0] o, output logic [3:0] o2);
  assign o = C.n;  assign o2 = C.e;
endmodule
module m_flat #(parameter p::flat_t C = p::bflat()) (output logic [31:0] o, output logic [7:0] o2);
  assign o = C.n;  assign o2 = C.t;
endmodule

module dut (output logic [31:0] a, b, c, d, e);
  logic [31:0] x1, x2; logic [47:0] x3; logic [3:0] x4; logic [7:0] x5;
  m_nest_pat u1 (.o(a), .o2(x1));
  m_nest_mem u2 (.o(b), .o2(x2));
  m_arr      u3 (.o(c), .o2(x3));
  m_enum     u4 (.o(d), .o2(x4));
  m_flat     u5 (.o(e), .o2(x5));
endmodule
