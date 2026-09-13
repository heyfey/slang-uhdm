// v11 — THE FAMILY INSIDE A GENERATE SCOPE and on an INTERFACE holder.
package p;
  typedef struct packed {
    int unsigned a;
    bit f1;
    bit f2;
  } ucfg_t;
  typedef struct packed {
    ucfg_t u;
    int unsigned d;
  } cfg_t;
  function automatic ucfg_t setc();
    ucfg_t c;
    c.a = 7;
    c.f1 = 1'b1;
    c.f2 = 1'b0;
    return c;
  endfunction
  function automatic cfg_t build(input ucfg_t u);
    cfg_t r;
    r.u = u;
    r.d = u.a * 2;
    return r;
  endfunction
  localparam ucfg_t U = setc();
  localparam cfg_t C = build(U);
endpackage

interface cfg_if #(
  parameter p::cfg_t Cfg = p::C
) ();
  logic v;
endinterface

module leaf #(
  parameter p::cfg_t Cfg = '0
) (
  input  logic x,
  output logic y
);
  assign y = Cfg.u.f1 ? x : 1'b0;
endmodule

module top (
  input  logic x,
  output logic y,
  output logic z
);
  localparam p::cfg_t TC = p::C;
  cfg_if #(.Cfg(p::C)) u_if ();
  generate
    if (TC.u.f1) begin : g_on
      leaf #(.Cfg(TC)) u_l (.x(x), .y(y));
    end else begin : g_off
      assign y = 1'b0;
    end
  endgenerate
  assign z = u_if.v;
endmodule
