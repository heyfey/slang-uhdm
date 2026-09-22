// v12 -- a module instantiated INSIDE a generate block; its classes stay ITS own.
module leaf ();
  class Zleaf; int z; endclass
  class Aleaf; int a; endclass
endmodule
module sub ();
  generate
    if (1) begin : g
      leaf u_l ();
    end
  endgenerate
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
