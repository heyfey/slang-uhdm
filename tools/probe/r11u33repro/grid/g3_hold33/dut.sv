// r11u33 grid arm g3_hold33 — THE HOLDER and THE VIEW.
//
// The same three bound shapes inside a MODULE that is instantiated twice
// (default and overridden), inside an INTERFACE, and inside a PACKAGE, so the
// DEF listing and every ELAB listing of each can be read for the same written
// bound.  The override arm is what separates "the declared width" from "the
// override actual's stored width".
package g3pk33;
  parameter int unsigned PU = 4;
  parameter int unsigned PV = 2;
  logic [PU:0]    pv_nu;
  logic [PU+PV:0] pv_add;
  logic [PU-1:0]  pv_sub;
  logic pa_nu [PU:1];
endpackage

interface g3if33 #(parameter int unsigned IU = 6, parameter int unsigned IV = 2) ();
  logic [IU:0]    if_nu;
  logic [IU+IV:0] if_add;
  logic [IU-1:0]  if_sub;
  logic if_arr [IU:1];
  modport m (input if_nu);
endinterface

module g3leaf33 #(
    parameter int unsigned NU = 5,
    parameter int unsigned MU = 3
) (
    input logic clk,
    input logic [NU:0] i_nu
);
  logic [NU:0]    v_nu;
  logic [NU+MU:0] v_add;
  logic [NU-1:0]  v_sub;
  logic a_nu [NU:1];
  always_ff @(posedge clk) v_nu <= '0;
endmodule

module g3_hold33 (input logic clk);
  g3if33 s();
  // DEFAULT instance: the bound folds at the DECLARED width.
  g3leaf33 u_def (.clk(clk), .i_nu('0));
  // OVERRIDDEN with a bare decimal.
  g3leaf33 #(.NU(9), .MU(4)) u_lit (.clk(clk), .i_nu('0));
  // OVERRIDDEN with a bare NAME of a typed localparam.
  localparam int unsigned TOP_NU = 12;
  localparam byte         TOP_NB = 10;
  g3leaf33 #(.NU(TOP_NU)) u_nam (.clk(clk), .i_nu('0));
  // OVERRIDDEN with a bare NAME of a NARROWER type.
  g3leaf33 #(.NU(TOP_NB)) u_byt (.clk(clk), .i_nu('0));
  // OVERRIDDEN with an EXPRESSION.
  g3leaf33 #(.NU(TOP_NU + 1)) u_exp (.clk(clk), .i_nu('0));
endmodule
