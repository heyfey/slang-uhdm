// § sizeBitNetIsVar228 § parseViewSizeExprEval228 — a bit net port of an interface, read in the interface and in a generate block of the child
interface bus (input bit [3:0][1:0] ib);
  wire [7:0] w1 = $size(ib);
endinterface
module sub (input bit [2:0][1:0] pp, output logic [7:0] o1);
  if (1) begin : g
    wire [7:0] w = $size(pp);
    assign o1 = w;
  end
endmodule
module dut (input bit [3:0][1:0] i, output logic [7:0] o1, o2);
  bus b (.ib(i));
  sub u (.pp(i[2:0]), .o1(o1));
  assign o2 = b.w1;
endmodule
