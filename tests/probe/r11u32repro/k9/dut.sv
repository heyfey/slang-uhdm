// r11u32 K9 probe — does the LANDED "a local net typed by a typedef used as a
// child instance's `type` parameter argument stays a bare logic_net in the def
// view" clause (defNetOmitsTypespec224, ModuleEmit.cpp:806) have a header gate
// golden applies and we do not?
//
// Four arms over one axis pair: module header ANSI vs NON-ANSI, and the local
// typedef PASSED as a `type` argument vs NOT passed.  Read the DEF-view net's
// vpiTypespec in each.
package k9pk;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } q_t;
endpackage

module k9child #(parameter type ft = logic) (input ft fi, output logic o);
  assign o = |{fi};
endmodule

// A: ANSI header, typedef PASSED as a type argument      (struct_member_cfg_width's shape)
module k9_ansi_passed (input logic [7:0] pa, output logic o);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } t_t;
  t_t n_ansi_passed;
  assign n_ansi_passed = pa;
  k9child #(.ft(t_t)) c (.fi(n_ansi_passed), .o(o));
endmodule

// B: NON-ANSI header, typedef PASSED as a type argument
module k9_nonansi_passed (pa, o);
  input logic [7:0] pa;
  output logic o;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } t_t;
  t_t n_nonansi_passed;
  assign n_nonansi_passed = pa;
  k9child #(.ft(t_t)) c (.fi(n_nonansi_passed), .o(o));
endmodule

// C: ANSI header, typedef NOT passed
module k9_ansi_plain (input logic [7:0] pa, output logic o);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } t_t;
  t_t n_ansi_plain;
  assign n_ansi_plain = pa;
  assign o = |{n_ansi_plain};
endmodule

// D: NON-ANSI header, typedef NOT passed
module k9_nonansi_plain (pa, o);
  input logic [7:0] pa;
  output logic o;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } t_t;
  t_t n_nonansi_plain;
  assign n_nonansi_plain = pa;
  assign o = |{n_nonansi_plain};
endmodule

module tb;
  logic [7:0] pa; logic o1, o2, o3, o4;
  k9_ansi_passed     u1 (.pa(pa), .o(o1));
  k9_nonansi_passed  u2 (.pa(pa), .o(o2));
  k9_ansi_plain      u3 (.pa(pa), .o(o3));
  k9_nonansi_plain   u4 (.pa(pa), .o(o4));
endmodule
