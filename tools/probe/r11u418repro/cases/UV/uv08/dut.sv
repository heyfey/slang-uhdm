// § unitVarRefMintsNet418
logic flag;
module top;
  initial begin
    flag = 1'b1;
    #1 $display("%b", flag);
  end
endmodule
