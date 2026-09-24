// v04 -- BOTH arms of a generate if/else carry a class.
module sub ();
  generate
    if (0) begin : gt
      class Cthen; int x; endclass
    end
    else begin : ge
      class Celse; int y; endclass
    end
  endgenerate
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
