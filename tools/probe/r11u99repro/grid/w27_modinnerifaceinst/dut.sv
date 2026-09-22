// a portless nested INTERFACE that is also instantiated inside the outer
module sub;
  logic q;
  interface innerif;
    logic w;
  endinterface
  innerif u_n();
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
