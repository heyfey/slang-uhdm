// v11u77 vd -- LAW B face: structMembersAllLogic77's member walk.  It unwraps
// packed arrays to a ScalarType leaf and demands four-state; an enum member, a
// bit member, a packed-array-of-struct member and a SIGNED logic member are
// each asked of golden here.
package ps;
  typedef struct packed { logic [7:0] x; logic [7:0] y; }  base_t;
  typedef enum logic [1:0] { QA, QB } e_t;
  typedef struct packed { e_t m;        logic [7:0] y; }   s_enum_t;
  typedef struct packed { bit [7:0] m;  logic [7:0] y; }   s_bit_t;
  typedef struct packed { base_t [1:0] m; logic [7:0] y; } s_pastruct_t;
  typedef struct packed { logic signed [7:0] m; logic y; } s_signed_t;
  typedef struct packed { logic [1:0][7:0] m; logic y; }   s_pa_t;
  s_enum_t     v_senum;
  s_bit_t      v_sbit;
  s_pastruct_t v_spas;
  s_signed_t   v_ssgn;
  s_pa_t       v_spa;
endpackage

module dut (output logic [31:0] o);
  import ps::*;
  for (genvar i = 0; i < 1; i = i + 1) begin : gv
    logic [31:0] v_senum; assign v_senum = 32'd1;
    logic [31:0] v_sbit;  assign v_sbit  = 32'd2;
    logic [31:0] v_spas;  assign v_spas  = 32'd3;
    logic [31:0] v_ssgn;  assign v_ssgn  = 32'd4;
    logic [31:0] v_spa;   assign v_spa   = 32'd5;
  end
  assign o = gv[0].v_senum ^ gv[0].v_sbit ^ gv[0].v_spas ^ gv[0].v_ssgn
           ^ gv[0].v_spa;
endmodule
