// a DOUBLY nested module, explicitly instantiated in its parent
module sub ();
  module mid ();
    module deep (); wire [31:0] r = 32'd3; endmodule
    deep u_d ();
  endmodule
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
