// v11u93 x4 -- a CASE generate in a program: the unmatched arms too?
program prg ();
  parameter int P = 1;
  wire [31:0] w_plain = 32'd11;
  generate
    case (P)
      0: begin : g0
        wire [31:0] w_c0 = 32'd20;
        initial $display("zero");
      end
      1: begin : g1
        wire [31:0] w_c1 = 32'd21;
        initial $display("one");
      end
      default: begin : gd
        wire [31:0] w_cd = 32'd22;
        initial $display("def");
      end
    endcase
  endgenerate
endprogram
module dut (output logic [31:0] o);
  prg u_p ();
  assign o = 32'd0;
endmodule
