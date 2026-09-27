// § blockSizeDimEndsAtExpr183 (packed element, size N*2)
module top #(parameter int N = 2) (output logic [7:0] o);
  task automatic t(output logic [7:0] r);
    begin
      logic [7:0] q[N*2];
      q[1] = 8'h3;
      r = q[1];
    end
  endtask
  initial t(o);
endmodule
