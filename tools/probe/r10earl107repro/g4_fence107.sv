// r10earl107 grid arm g4_fence107 -- MEASUREMENT ONLY.
// THE FENCES: every carrier that is NOT a port high_conn of a packed-struct
// PARAMETER reference, each with an unsized member value.
package pg4_107;
  typedef struct packed { logic [5:0] f6; logic [1:0] f2; } fs_t;
  parameter fs_t FS_DEF = '{ f6:'1, f2:'0 };
  typedef struct packed { logic [3:0] g4; } g_t;
  parameter g_t GA [0:1] = '{ '{g4:'1}, '{g4:'0} };
  parameter logic [7:0] PLAIN = '1;
endpackage

module child4_107 (
  input pg4_107::fs_t a,
  input pg4_107::fs_t b,
  input logic [7:0]   c,
  input pg4_107::fs_t d
);
  logic u; assign u = ^{a,b,c,d};
endmodule

module g4_fence107 (input logic clk, output logic [7:0] o);
  // A: a cont_assign carrier (r10earl61's own, must stay byte-identical)
  pg4_107::fs_t caw;
  assign caw = '{ f6:'1, f2:'0 };
  // B: a module-body param_assign carrier
  localparam pg4_107::fs_t LOC = '{ f6:'0, f2:'1 };
  // C: a pattern written INLINE at the connection (not a param reference)
  // D: a NON-struct param at a port
  // E: a var declaration initializer
  pg4_107::fs_t vdi = '{ f6:'1, f2:'1 };
  child4_107 u_c (
    .a (pg4_107::FS_DEF),
    .b ('{ f6:'1, f2:'0 }),
    .c (pg4_107::PLAIN),
    .d (LOC)
  );
  assign o = {caw, vdi[1:0]} | {8{clk}};
endmodule
