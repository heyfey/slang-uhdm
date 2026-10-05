// § unitLawSGenVarIsInstVar245v
// a $unit bit typedef variable in a case-generate branch with a parameter
typedef bit [1:0] pr_t;
module top #(parameter int P = 1) (input logic [1:0] i, output logic [1:0] o);
  case (P)
    1: begin : c
      pr_t v;
    end
    default: begin : d
      pr_t w;
    end
  endcase
  assign c.v = i;
  assign o = c.v;
endmodule
