// r10v63 — V5: the F4 ARGUMENT fence and its neighbours.  Every argument
// shape: integral literal / integral param / unpacked array / packed array /
// packed struct / string / real / enum / 2-D unpacked / no-argument, each with
// a body whose producer the law claims to know.  If F4 is drawn in the wrong
// place, the cell that should keep the OLD BIN arm will move.
// MEASUREMENT ONLY.
typedef struct packed { logic [3:0] a; logic [3:0] b; } sp_t;
typedef enum logic [3:0] { Q0 = 0, Q5 = 5 } q_t;

function automatic int mk_one(int i); return i + 3; endfunction
function automatic integer g_arr (int a[3]);        return a[0] - 1;      endfunction
function automatic integer g_arrt(int a[3]);        return (a[0]==1)?1:$clog2(a[0]); endfunction
function automatic integer g_pk  (logic [7:0] a);   return a - 1;         endfunction
function automatic integer g_sp  (sp_t a);          return a.a - 1;       endfunction
function automatic integer g_str (string a);        return 4 - 1;         endfunction
function automatic integer g_rl  (real a);          return 4 - 1;         endfunction
function automatic integer g_en  (q_t a);           return a - 1;         endfunction
function automatic integer g_non ();                return 300 - 1;       endfunction
function automatic integer g_two (integer a, int b[3]); return a + b[1] - 1; endfunction

module s_arg #(parameter int V = 300) (output logic o);
  localparam int            A_LIT [3] = '{3,5,4};
  localparam sp_t           SP     = 8'h35;
  localparam int  a_arrl  = g_arr(A_LIT);
  localparam int  a_pk    = g_pk(8'hf0);
  localparam int  a_sp    = g_sp(SP);
  localparam int  a_str   = g_str("hi");
  localparam int  a_rl    = g_rl(2.5);
  localparam int  a_en    = g_en(Q5);
  localparam int  a_non   = g_non();
  localparam int  a_twol  = g_two(V, A_LIT);
  localparam logic [15:0] b_arrl = g_arr(A_LIT);
  assign o = |{a_arrl[0],a_pk[0],a_sp[0],a_str[0],a_rl[0],
               a_en[0],a_non[0],a_twol[0],b_arrl[0]};
endmodule

module top(output logic o1, output logic o2);
  s_arg #(.V(300)) u1 (.o(o1));
  s_arg #(.V(1))   u2 (.o(o2));
endmodule
