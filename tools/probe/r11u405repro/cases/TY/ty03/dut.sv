// § typenameKwIsString405
module top();
logic v;
initial begin
  $display("%s", $typename(v));
end
endmodule
