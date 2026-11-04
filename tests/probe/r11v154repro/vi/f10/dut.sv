// § varInitDefNetModuleOnly154v
interface ifc;
   string s = "abcd";
   int k = 1;
   string t = s.substr(k, k + 1);
endinterface
module top; ifc i(); endmodule
