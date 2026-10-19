// § typenameKwIsString405
module top();
string s;
initial begin
  s = $typename(int);
  $display("%s %s", $typename(real), $typename(logic [3:0]));
end
endmodule
