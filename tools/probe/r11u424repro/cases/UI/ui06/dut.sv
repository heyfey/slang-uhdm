// § ifcUnitVarRefMintsNet424
string label = "X";
interface ifc(input bit clk, input read, input write);
  assert property (@(posedge clk) !(read & write)) else begin
    if (read) $error("%s", label);
  end
endinterface
module top;
  bit c; logic r, w;
  ifc d(.clk(c), .read(r), .write(w));
endmodule
