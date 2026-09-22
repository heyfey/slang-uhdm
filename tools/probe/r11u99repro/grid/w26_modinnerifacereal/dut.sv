// a portless INTERFACE declared inside a module (the shape Surelog accepts)
module sub;
  logic q;
  interface innerif;
    logic w;
  endinterface
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
