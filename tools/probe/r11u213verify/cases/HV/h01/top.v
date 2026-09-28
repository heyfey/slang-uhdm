// § hiddenBlockVarMintNoFile207 (every block kind: always, initial, a named begin inside a named begin, fork)
module m (clk, in, q);
input clk, in;
output q;
reg q;
always @(posedge clk) begin : ab
logic ah;
ah = in;
q = ah;
end
initial begin : ib
logic ih;
ih = 1'b0;
end
always @(in) begin : o1
begin : o2
logic nh;
nh = ~in;
end
end
initial fork : fk
logic fh;
fh = 1'b1;
join
endmodule
