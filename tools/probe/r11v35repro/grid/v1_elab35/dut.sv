// v1_elab35 — THE VIEW axis: does golden keep a type-parameter aggregate
// default's member bounds symbolic in the ELABORATED view too, per instance,
// when the width parameter is OVERRIDDEN per instance?  Negative controls in
// the same module: an anonymous struct on a variable, a named module typedef.
package cfgv35;
  localparam int PW = 12;
  typedef struct packed {
    int XLEN;
    int YLEN;
  } cfg_t;
  localparam cfg_t Cfg = '{XLEN: 32, YLEN: 16};
endpackage

typedef struct packed { logic [3:0] ov; } ovr35_t;

module sub35 #(parameter int W = 8,
               parameter type ANSI_T = struct packed { logic [W-1:0] pa; })
              (input logic clk);
  // THE LAW'S CELL: a localparam type whose default is an anonymous struct.
  localparam type loc_t = struct packed {
    logic [W-1:0]   a;
    logic [2*W-1:0] b;
  };
  loc_t lv;
  ANSI_T av;
  // NEGATIVE CONTROL 1 — an anonymous struct declared on a VARIABLE.
  struct packed { logic [W-1:0] na; } nv;
  // NEGATIVE CONTROL 2 — a NAMED module-scope struct typedef.
  typedef struct packed { logic [W-1:0] ta; } tnamed_t;
  tnamed_t tv;
  // NEGATIVE CONTROL 3 — a plain packed typedef (no aggregate).
  typedef logic [W-1:0] vec_t;
  vec_t vvv;
  always_comb begin
    lv = '0;
    av = '0;
    nv = '0;
    tv = '0;
    vvv = '0;
  end
endmodule

module v1_elab35 (input logic clk);
  sub35 #(.W(5))               u_a (.clk(clk));
  sub35                        u_b (.clk(clk));
  sub35 #(.W(7), .ANSI_T(ovr35_t)) u_c (.clk(clk));
endmodule
