// r11u95 a17 -- LOOP BOUND 0 with a NET-DECL-ASSIGN and a standalone assign.
program prg ();
  wire [31:0] w_plain = 32'd11;
  generate
    for (genvar i = 0; i < 0; i++) begin : g
      wire [31:0] w_loop;
      assign w_loop = 32'd12;
    end
  endgenerate
endprogram
module dut (output logic [31:0] o);
  prg u_p ();
  assign o = 32'd0;
endmodule
