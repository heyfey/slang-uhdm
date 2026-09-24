// v11u93 x18 -- CONTROL: the same shape in a MODULE home, body members too.
module sub ();
  wire [31:0] w_plain = 32'd11;
  function automatic int f_body(); return 3; endfunction
  initial $display("body");
  generate
    if (1) begin : g
      function automatic int f_gen(); return 7; endfunction
      task automatic t_gen(); endtask
      initial $display("hi");
    end
  endgenerate
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
