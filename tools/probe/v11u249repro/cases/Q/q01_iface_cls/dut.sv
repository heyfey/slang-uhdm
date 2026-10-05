// § clsPropWholeArrTd249 (clsTdArrElemPkgPath249 abstains on an interface class)
interface ifc;
  class c; typedef int f_t[2]; f_t m; endclass
  c h;
endinterface
module top; ifc i(); endmodule
