// v11u93 x12 -- an IMPORTED package function beside the flattened one.
package pk;
  function automatic int f_pkg(); return 5; endfunction
endpackage
program prg ();
  import pk::*;
  wire [31:0] w_plain = 32'd11;
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
