// § spanCopyCarriesFile125
interface st_if;
  logic v;
  assign v = 1'b0;
  bit d;
  initial begin
    d = 1'b1;
  end
endinterface
module top;
  st_if u();
endmodule
