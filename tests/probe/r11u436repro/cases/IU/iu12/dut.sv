// § cgArrayElemUnsupportedTs436
interface ifc (input clk, input a);
covergroup cg();
  coverpoint a;
endgroup
cg cgs[2];
initial begin
  foreach (cgs[i]) begin
    cgs[i] = new();
  end
end
endinterface
