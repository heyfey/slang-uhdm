// § ifcConcAssertListed424
interface ifc(input bit clk, input read, input write);
  assert property (@(posedge clk) read |=> write) else $error("x");
endinterface
module top();
  bit c; logic r, w;
  if (1) begin : g
    ifc d(.clk(c), .read(r), .write(w));
  end
endmodule
