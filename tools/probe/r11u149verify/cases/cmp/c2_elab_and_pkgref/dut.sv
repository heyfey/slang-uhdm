// § elabCloneInstTreeUnstored144 + § pkgRefFoldClonesMultiDimOnly140 (composition, --elabuhdm)
package ap;
  parameter logic [7:0][3:0] X = 32'habcd;
  parameter int XI = 5;
endpackage
module cc import ap::*; #(parameter logic [7:0][3:0] P = X, parameter int Q = XI, parameter logic Z = 0) (input logic [3:0] a, output logic y);
  for (genvar i = 0; i < 4; i++) begin : ST
    logic c;
    if (i == 0) begin : C
      assign c = a[0];
    end else begin : C
      assign c = ST[i - 1].c & a[i];
    end
  end
  assign y = ST[3].c;
endmodule
module top(input logic [3:0] a, output logic y);
  cc #(.Z(1)) u(.a(a), .y(y));
endmodule
