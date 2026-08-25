// r10earl84 arm g1 — THE HEAD MINIMISED, AND THE CONTEXTS AROUND IT.
// One and the same read (`localparam int Db = $clog2(4)`) as the BASE of the
// indexed_part_select that closes a hier_path, in every context this emitter
// can put it in.  ELAB port High_conn is the ONLY one the law claims.
package p84;
  parameter int AddrW = 17;
endpackage

module sink84 #(parameter int W = 8) (input logic [W-1:0] a);
endmodule
module isink84 #(parameter int W = 8) (output logic [W-1:0] a);
  assign a = '0;
endmodule
function automatic logic [16:0] uf84(input logic [16:0] x);
  return x;
endfunction

module head84;                       // c1 — THE HEAD, minimised
  import p84::*;
  typedef struct packed { logic [31:0] q; } f_t;
  typedef struct packed { f_t addr;      } r_t;
  r_t reg2hw;
  localparam int Db = $clog2(4);
  sink84 #(.W(AddrW)) u_h (.a(reg2hw.addr.q[Db +: AddrW]));
endmodule

module ctx84;
  import p84::*;
  typedef struct packed { logic [31:0] q; } f_t;
  typedef struct packed { f_t addr;      } r_t;
  r_t reg2hw;
  logic [16:0] w17;
  logic [16:0] o17;
  localparam int Db = $clog2(4);

  // c2 ELAB port High_conn, the head's own shape (three instances, one param)
  sink84 #(.W(AddrW)) u_c2a (.a(reg2hw.addr.q[Db +: AddrW]));
  sink84 #(.W(AddrW)) u_c2b (.a(reg2hw.addr.q[Db +: AddrW]));
  // c3 an OUTPUT port's High_conn (the same select as an lvalue)
  isink84 #(.W(AddrW)) u_c3 (.a(o17));
  // c4 a USER call inside the High_conn — fence (d), golden keeps the ref
  sink84 #(.W(AddrW)) u_c4 (.a(uf84(reg2hw.addr.q[Db +: AddrW])));
  // c5 a SYSTEM call inside the High_conn — NOT fenced
  sink84 #(.W(AddrW)) u_c5 (.a($unsigned(reg2hw.addr.q[Db +: AddrW])));
  // c6 nested one operation deep inside the High_conn
  sink84 #(.W(AddrW)) u_c6 (.a(reg2hw.addr.q[Db +: AddrW] | 17'd0));

  // c7 a module-body cont_assign (compiled Reduce::No)
  assign w17 = reg2hw.addr.q[Db +: AddrW];
  // c8 a procedural statement
  logic [16:0] pr17;
  always_comb pr17 = reg2hw.addr.q[Db +: AddrW];
  // c9 a procedural LVALUE
  logic [31:0] lv32;
  always_comb lv32[Db +: AddrW] = 17'd0;

  // c10 a GENERATE-scope High_conn and cont_assign
  for (genvar gi = 0; gi < 2; gi++) begin : gb
    logic [16:0] gw;
    sink84 #(.W(AddrW)) u_c10 (.a(reg2hw.addr.q[Db +: AddrW]));
    assign gw = reg2hw.addr.q[Db +: AddrW];
  end

  // c11 a declaration range bound (not a select at all)
  logic [Db:0] decl;
  assign decl = '0;
endmodule
