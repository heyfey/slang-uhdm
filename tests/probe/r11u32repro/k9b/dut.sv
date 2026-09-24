// r11u32 K9 probe 2 — widen the cell the first probe refuted.  The landed
// `typeParamArgTypes` clause (defNetOmitsTypespec224, ModuleEmit.cpp:806)
// strips a def-view net's typespec whenever the net's typedef is ALSO used as
// a child instance's `type` argument, with no header gate.  Probe 1 measured
// golden KEEPING the typespec in the ANSI cell.  This probe asks whether
// anything else in that cell strips it: the typedef's own KIND (struct /
// vector / enum / package-homed / scoped spelling) and an INITIALIZER.
package k9pk2;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } pq_t;
  typedef logic [7:0] pv_t;
endpackage

module k9bchild #(parameter type ft = logic) (input ft fi, output logic o);
  assign o = |{fi};
endmodule

// every arm: ANSI header, the typedef PASSED as a `type` argument
module k9b_struct (input logic [7:0] pa, output logic o);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } t_t;
  t_t b_struct;
  assign b_struct = pa;
  k9bchild #(.ft(t_t)) c (.fi(b_struct), .o(o));
endmodule

module k9b_vector (input logic [7:0] pa, output logic o);
  typedef logic [7:0] t_t;
  t_t b_vector;
  assign b_vector = pa;
  k9bchild #(.ft(t_t)) c (.fi(b_vector), .o(o));
endmodule

module k9b_enum (input logic [7:0] pa, output logic o);
  typedef enum logic [2:0] { Z0, Z1 } t_t;
  t_t b_enum;
  assign b_enum = t_t'(pa[2:0]);
  k9bchild #(.ft(t_t)) c (.fi(b_enum), .o(o));
endmodule

module k9b_pkg_unqual import k9pk2::*; (input logic [7:0] pa, output logic o);
  pq_t b_pkg_unqual;
  assign b_pkg_unqual = pa;
  k9bchild #(.ft(pq_t)) c (.fi(b_pkg_unqual), .o(o));
endmodule

module k9b_pkg_scoped (input logic [7:0] pa, output logic o);
  k9pk2::pq_t b_pkg_scoped;
  assign b_pkg_scoped = pa;
  k9bchild #(.ft(k9pk2::pq_t)) c (.fi(b_pkg_scoped), .o(o));
endmodule

// the same struct arm with an INITIALIZER on the declaration
module k9b_init (input logic [7:0] pa, output logic o);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } t_t;
  var t_t b_init = '0;
  k9bchild #(.ft(t_t)) c (.fi(b_init), .o(o));
endmodule

// NON-ANSI control: probe 1 measured golden STRIPPING here
module k9b_nonansi (pa, o);
  input logic [7:0] pa;
  output logic o;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } t_t;
  t_t b_nonansi;
  assign b_nonansi = pa;
  k9bchild #(.ft(t_t)) c (.fi(b_nonansi), .o(o));
endmodule

module tb;
  logic [7:0] pa; logic o1,o2,o3,o4,o5,o6,o7;
  k9b_struct      u1 (.pa(pa), .o(o1));
  k9b_vector      u2 (.pa(pa), .o(o2));
  k9b_enum        u3 (.pa(pa), .o(o3));
  k9b_pkg_unqual  u4 (.pa(pa), .o(o4));
  k9b_pkg_scoped  u5 (.pa(pa), .o(o5));
  k9b_init        u6 (.pa(pa), .o(o6));
  k9b_nonansi     u7 (.pa(pa), .o(o7));
endmodule
