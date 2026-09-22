// v11u93 x26 -- the import, a BODY function and a GEN function: which order?
package pk;
  function automatic int f_pkg(); return 5; endfunction
endpackage
program prg ();
  import pk::*;
  function automatic int f_body(); return 3; endfunction
  generate
    if (1) begin : g
      function automatic int f_gen(); return 7; endfunction
    end
  endgenerate
  initial begin
    $display("%0d", f_pkg());
  end
endprogram
module dut (output logic [31:0] o);
  prg u_p ();
  assign o = 32'd0;
endmodule
