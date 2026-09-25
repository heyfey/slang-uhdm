// § varInitDefNetModuleOnly154v § varInitStrMethodArgDefNet154
interface ifc; string s = "xy"; string t = "x"; int b = s.compare(t); endinterface
module m(ifc p); string a = "abc"; string c = "a"; int d = a.compare(c); endmodule
module top; ifc i(); m u(i); endmodule
