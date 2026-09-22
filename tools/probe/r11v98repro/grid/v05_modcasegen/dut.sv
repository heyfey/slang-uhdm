// v05 -- a CASE generate, two arms, each with a class.
module sub #(parameter int P = 1) ();
  generate
    case (P)
      0: begin : c0
        class Czero; int x; endclass
      end
      default: begin : cd
        class Adef; int y; endclass
      end
    endcase
  endgenerate
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
