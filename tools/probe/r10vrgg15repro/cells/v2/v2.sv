// v2 — FILL SHAPES ('0 '1 'x 'z) as override actuals into many formal widths.
module g_b1   #(parameter bit   [0:0]        P = '0) (); endmodule
module g_b2   #(parameter bit   [1:0]        P = '0) (); endmodule
module g_b33  #(parameter bit  [32:0]        P = '0) (); endmodule
module g_b64  #(parameter bit  [63:0]        P = '0) (); endmodule
module g_b65  #(parameter bit  [64:0]        P = '0) (); endmodule
module g_b128 #(parameter bit [127:0]        P = '0) (); endmodule
module g_l6   #(parameter logic [5:0]        P = '0) (); endmodule
module g_int  #(parameter int                P = '0) (); endmodule

module v2;
  g_b1   #('1) o_b1   ();  g_b1   #('x) x_b1   ();  g_b1   #('z) z_b1   ();
  g_b2   #('1) o_b2   ();  g_b2   #('x) x_b2   ();  g_b2   #('z) z_b2   ();
  g_b33  #('1) o_b33  ();  g_b33  #('x) x_b33  ();  g_b33  #('z) z_b33  ();
  g_b64  #('1) o_b64  ();  g_b64  #('x) x_b64  ();  g_b64  #('z) z_b64  ();
  g_b65  #('1) o_b65  ();  g_b65  #('x) x_b65  ();  g_b65  #('z) z_b65  ();
  g_b128 #('1) o_b128 ();  g_b128 #('x) x_b128 ();  g_b128 #('z) z_b128 ();
  g_l6   #('1) o_l6   ();  g_l6   #('x) x_l6   ();  g_l6   #('z) z_l6   ();
  g_int  #('1) o_int  ();  g_int  #('x) x_int  ();  g_int  #('z) z_int  ();
endmodule
