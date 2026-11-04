// § varInitDefNetModuleOnly154v
interface ifc;
   string s = "abcd";
   string t = "ab";
   int  b = s.compare(t);
endinterface
module m(ifc i); endmodule
module top; ifc i(); m u(i); endmodule
