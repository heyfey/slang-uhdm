module top (in);
input in;
ifc i ();
always @(posedge in) begin : keep
logic hold;
hold = in;
end
endmodule
