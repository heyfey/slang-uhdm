// v11u93 x3 -- THREE LEVELS: if -> for(2) -> if, every kind at the bottom.
program prg ();
  wire [31:0] w_plain = 32'd11;
  generate
    if (1) begin : g1
      wire [31:0] w_g1 = 32'd12;
      for (genvar i = 0; i < 2; i++) begin : g2
        wire [31:0] w_g2 = 32'd13;
        if (1) begin : g3
          wire [31:0] w_g3 = 32'd14;
          class Cdeep; int x; endclass
          function automatic int f_deep(); return 7; endfunction
          task automatic t_deep(); endtask
          initial begin
            $display("deep");
          end
        end
      end
    end
  endgenerate
endprogram
module dut (output logic [31:0] o);
  prg u_p ();
  assign o = 32'd0;
endmodule
