// § uninstIfaceIncDecBinds441
interface ifc(input logic clk);
int garr[4];
int m;
always @(posedge clk) begin
  int k;
  garr[k]++;
  m++;
end
function automatic void f(ref int r, input int s); r++; s -= 1; garr[s]--; endfunction
endinterface
