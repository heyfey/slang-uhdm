// r11u77 y4 — THE BIND TABLE IS NOT THE KIND TABLE.
// § genCaLhsArrayNetNeverBinds17: Surelog's `bindVariable` searches
// Variables() then Nets() and NEVER Array_nets(), so an unpacked-array NET
// holder is materialised and still binds nothing, while an unpacked-array
// VARIABLE (an `array_var`, which lives in Variables()) binds.  This arm
// grids the two tables against each other on the IMPORT road and against the
// module-body road (the in-arm control, which pass 75 already measured).
package pr;
  wire  [7:0]  r_narr [0:1];   // array_net  -> listed, must NOT bind
  logic [7:0]  r_varr [0:1];   // array_var  -> listed AND binds
  typedef struct packed { logic [7:0] x; logic [7:0] y; } rs_t;
  rs_t         r_st;           // struct_net -> listed AND binds
  wire  [31:0] r_net;          // logic_net  -> listed AND binds
  logic [31:0] r_var;          // logic_var  -> listed AND binds
endpackage

module dut (output logic [31:0] o);
  import pr::*;
  wire  [7:0]  m_narr [0:1];   // the MODULE-BODY control (pass 75's xb_arrnet)
  logic [7:0]  m_varr [0:1];
  for (genvar i = 0; i < 1; i = i + 1) begin : gr
    logic [31:0] r_narr;  assign r_narr = 32'd1;
    logic [31:0] r_varr;  assign r_varr = 32'd2;
    logic [31:0] r_st;    assign r_st   = 32'd3;
    logic [31:0] r_net;   assign r_net  = 32'd4;
    logic [31:0] r_var;   assign r_var  = 32'd5;
    logic [31:0] m_narr;  assign m_narr = 32'd6;
    logic [31:0] m_varr;  assign m_varr = 32'd7;
  end
  assign o = gr[0].r_narr ^ gr[0].r_varr ^ gr[0].r_st ^ gr[0].r_net
           ^ gr[0].r_var  ^ gr[0].m_narr ^ gr[0].m_varr;
endmodule
