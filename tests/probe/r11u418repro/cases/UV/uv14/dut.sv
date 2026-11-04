// § unitVarRefMintsNet418
string label = "X";
module top;
  logic [7:0] v;
  initial begin
    v = 1;
    $display("%s %0d", label, v);
    $display("%s", label);
  end
endmodule
