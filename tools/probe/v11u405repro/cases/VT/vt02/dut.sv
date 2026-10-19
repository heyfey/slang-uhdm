// § typenameKwIsString405
module top();
initial begin
  $display("%s %s", $typename(logic signed), $typename(bit [7:0]));
end
endmodule
