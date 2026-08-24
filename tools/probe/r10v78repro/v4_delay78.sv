// r10v78 arm v4 — the DELAY fence.  UhdmWriter::writeCont_assign clones the
// assign FIRST when the delay is a `ref_obj` (a parameter), and the whole
// reduce block is then guarded by `if (cloned == false)` — so a
// parameter-delayed cont_assign is NEVER reduced by Surelog.  A LITERAL delay
// is a constant, not a ref_obj, so it still reduces.  Plus the gen HOMES.
module v4sub();
  localparam int TW = 6;
  parameter  int DLY = 2;
  logic [3:0] d_par, d_lit, d_none, d_mm;
  logic [3:0] h_for0, h_for1, h_for2, h_case, h_nest;
  if (TW > 0) begin : g5
    assign #DLY d_par  = {TW{1'b1}};   // D1  delay is a PARAM ref  -> no reduce
    assign #3   d_lit  = {TW{1'b1}};   // D2  delay is a LITERAL    -> reduces
    assign      d_none = {TW{1'b1}};   // D3  no delay              -> reduces
    assign #(DLY) d_mm = {TW{1'b1}};  // D4  parenthesised param delay
  end
  for (genvar gi = 0; gi < 3; gi++) begin : g_for
    if (gi == 0) assign h_for0 = {TW{1'b1}};
    else if (gi == 1) assign h_for1 = {TW{1'b1}};
    else assign h_for2 = {TW{1'b1}};
  end
  case (TW)
    6: begin : g_case
      assign h_case = {TW{1'b1}};
    end
    default: begin : g_case_d
      assign h_case = {TW{1'b0}};
    end
  endcase
  if (TW > 0) begin : g_o
    for (genvar gj = 0; gj < 1; gj++) begin : g_m
      if (TW > 1) begin : g_i
        assign h_nest = {TW{1'b1}};   // three gen scopes deep
      end
    end
  end
endmodule

interface v4if();
  localparam int IW = 6;
  logic [3:0] if_t;
  if (IW > 0) begin : g_if
    assign if_t = {IW{1'b1}};          // an INTERFACE-body Lhs from its gen
  end
endinterface

program v4pg();
  localparam int PW = 6;
  logic [3:0] pg_t;
  if (PW > 0) begin : g_pg
    assign pg_t = {PW{1'b1}};          // a PROGRAM gen scope
  end
endprogram

module v4;
  v4sub u_a();
  v4sub u_b[0:1]();                    // an INSTANCE ARRAY
  v4if  u_if();
  v4pg  u_pg();
endmodule
