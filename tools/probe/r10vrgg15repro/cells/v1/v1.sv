// v1 — DECLARED-TYPE / WIDTH sweep, '0 override actual vs plain default.
module f_b1   #(parameter bit   [0:0]        P = '0) (); endmodule
module f_b2   #(parameter bit   [1:0]        P = '0) (); endmodule
module f_b33  #(parameter bit  [32:0]        P = '0) (); endmodule
module f_b64  #(parameter bit  [63:0]        P = '0) (); endmodule
module f_b65  #(parameter bit  [64:0]        P = '0) (); endmodule
module f_b128 #(parameter bit [127:0]        P = '0) (); endmodule
module f_l6   #(parameter logic [5:0]        P = '0) (); endmodule
module f_int  #(parameter int                P = '0) (); endmodule
module f_intg #(parameter integer            P = '0) (); endmodule
module f_byte #(parameter byte               P = '0) (); endmodule
module f_sgn  #(parameter logic signed [7:0] P = '0) (); endmodule
module f_shrt #(parameter shortint           P = '0) (); endmodule
module f_lng  #(parameter longint            P = '0) (); endmodule
module f_unt  #(parameter                    P = '0) (); endmodule

module v1;
  f_b1   #('0) u_b1   ();
  f_b2   #('0) u_b2   ();
  f_b33  #('0) u_b33  ();
  f_b64  #('0) u_b64  ();
  f_b65  #('0) u_b65  ();
  f_b128 #('0) u_b128 ();
  f_l6   #('0) u_l6   ();
  f_int  #('0) u_int  ();
  f_intg #('0) u_intg ();
  f_byte #('0) u_byte ();
  f_sgn  #('0) u_sgn  ();
  f_shrt #('0) u_shrt ();
  f_lng  #('0) u_lng  ();
  f_unt  #('0) u_unt  ();
  f_b1   d_b1   ();
  f_b2   d_b2   ();
  f_b33  d_b33  ();
  f_b64  d_b64  ();
  f_b65  d_b65  ();
  f_b128 d_b128 ();
  f_l6   d_l6   ();
  f_int  d_int  ();
  f_intg d_intg ();
  f_byte d_byte ();
  f_sgn  d_sgn  ();
  f_shrt d_shrt ();
  f_lng  d_lng  ();
  f_unt  d_unt  ();
endmodule
