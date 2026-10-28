// § ifcAnsiLogicPortNet450
interface cnt_if (input logic clk, input logic rst, output logic [3:0] q, output logic wrap);
always_ff @(posedge clk) begin
  if (rst) q <= 4'd0;
  else q <= q + 4'd1;
end
always_comb wrap = (q == 4'hf);
endinterface
module top (input logic clk, input logic rst, output logic [3:0] q, output logic w);
  cnt_if u (.clk(clk), .rst(rst), .q(q), .wrap(w));
endmodule
