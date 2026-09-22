// v11u93 x17 -- CONTROL: the same shape in an INTERFACE home.
interface ifc ();
  wire [31:0] w_plain = 32'd11;
  generate
    if (1) begin : g
      function automatic int f_gen(); return 7; endfunction
      task automatic t_gen(); endtask
      initial $display("hi");
      class C; int x; endclass
    end
  endgenerate
endinterface
module dut (output logic [31:0] o);
  ifc u_i ();
  assign o = 32'd0;
endmodule
