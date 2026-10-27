// § uninstIfaceIncDecBinds441
interface ifc;
  logic clk;
  int garr[4];
  always @(posedge clk) begin
    automatic int k = 1;
    --k;
    garr[k]--;
  end
endinterface
