// LAW B: three outers, instantiated in REVERSE name order, same nested name
module amod (); module innermod (); wire a1; endmodule endmodule
module bmod (); module innermod (); wire b1; endmodule endmodule
module cmod (); module innermod (); wire c1; endmodule endmodule
module dut (output logic [31:0] o);
  cmod u_c ();
  bmod u_b ();
  amod u_a ();
  assign o = 32'd0;
endmodule
