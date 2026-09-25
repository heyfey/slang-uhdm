// § varInitDefNetModuleOnly154v
interface ifc;
   string s = "abcd";
   string t = "ab";
   int  b = s.compare(t);
endinterface
module top; ifc i(); endmodule
