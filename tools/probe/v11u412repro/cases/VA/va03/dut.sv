// § assocClassIdxNet412
class C; endclass
interface ifc;
  int arr [C];
endinterface
module top;
  ifc i();
  for (genvar g = 0; g < 1; g++) begin : gb
    int garr [C];
  end
endmodule
