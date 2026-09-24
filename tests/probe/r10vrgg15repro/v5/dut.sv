// v5 — the FORMAL'S WIDTH IS ITSELF A PARAMETER, overridden per instance.
module w #(parameter int W = 8, parameter bit [W-1:0] P = '0) (); endmodule
module ws #(parameter int W = 8, parameter logic signed [W-1:0] S = '0) (); endmodule
module v5;
  w #(1,   '0) i1   ();
  w #(2,   '0) i2   ();
  w #(33,  '0) i33  ();
  w #(64,  '0) i64  ();
  w #(65,  '0) i65  ();
  w #(128, '0) i128 ();
  w #(.W(7),  .P('0)) i7  ();
  w #(.P('0))         i8d ();
  w #(.W(9))          i9d ();
  ws #(12, '0) s12 ();
  ws #(12, '1) s12o ();
endmodule
