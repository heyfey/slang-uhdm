// § nonblockingSelLhsBindsWholeRef151
module top(input logic a, output logic [3:0] y);
  logic [3:0] v;
  initial begin
    fork
      v[1] <= a;
    join
    y <= v;
  end
endmodule
