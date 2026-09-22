// v21 -- two classes in ONE generate block, declared Z then A.
module sub ();
  generate
    if (1) begin : g
      class Zg; int z; endclass
      class Ag; int a; endclass
    end
  endgenerate
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
