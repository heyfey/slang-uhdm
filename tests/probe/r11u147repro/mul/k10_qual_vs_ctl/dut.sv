// § gcaUseSiteParamConst147 (control: a package-qualified var_select base keeps pristine's name; residue)
package q;
  parameter logic [3:0][7:0] A = {8'h9, 8'ha, 8'hb, 8'hc};
endpackage
module top #(parameter int DW = 8) (output logic [7:0] o);
  for (genvar g = 0; g < 1; g++) begin : gb
    logic [7:0] c;
    assign c = q::A[g][DW-1:0];
  end
  assign o = '0;
endmodule
