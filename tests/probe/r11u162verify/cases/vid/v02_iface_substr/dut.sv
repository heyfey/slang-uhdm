// § varInitDefNetModuleOnly154v
interface ifc;
  string s = "abcdef";
  int k = 1;
  string u = s.substr(k, 3);
endinterface
module top; ifc i(); endmodule
