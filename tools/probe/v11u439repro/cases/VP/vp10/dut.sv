// § uninstProgBodyAsUninstIface439
program prg(input logic clk, output logic [3:0] o);
logic [3:0] cnt;
initial begin
  cnt = 0;
  @(posedge clk);
  o = cnt + 1;
  if (cnt == 0) o = 4'h1; else o = 4'h2;
  case (cnt) 0: o = 1; default: o = 3; endcase
end
endprogram
