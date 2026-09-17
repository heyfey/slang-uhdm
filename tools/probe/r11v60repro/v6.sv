// v6 — the PATTERN-VALUED ELEMENT fence at the import-copy face on a PACKED
// struct (g5 measures the unpacked spelling only), plus a symbolic-member-dim
// struct, plus a packed control.
package p6n;
  parameter int WD = 8;
  typedef struct packed { logic [7:0] x; logic [7:0] y; } pin_t;
  typedef struct packed { pin_t ip; logic [7:0] k; }      pnest_t;
  typedef struct packed { logic [WD-1:0] a; logic [7:0] b; } psym_t;
  typedef struct packed { logic [7:0] a; logic [7:0] b; }  pok_t;
  localparam pnest_t PNEST = '{ip: '{x: 8'd2, y: 8'd3}, k: 8'd6};
  localparam psym_t  PSYM  = '{a: 8'd1, b: 8'd2};
  localparam pok_t   POK   = '{a: 8'd4, b: 8'd8};
  function automatic int unsigned pf6n();   // never called
    return PNEST.k + PSYM.b + POK.a;
  endfunction
endpackage

module v6q import p6n::*; (input logic clk, output logic [7:0] d);
  assign d = '0;
endmodule

module v6top(input logic clk);
  logic [7:0] dd;
  v6q u_q (.clk(clk), .d(dd));
endmodule
