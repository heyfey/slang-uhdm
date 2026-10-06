// § forInitSelectLhsBase254 (an interface-port member and a virtual-interface member as the initializer target)
interface ifc; int cnt; logic [3:0] v; endinterface
module top(ifc ip, output int o);
  initial begin
    o = 0;
    for (ip.cnt = 0; ip.cnt < 3; ip.cnt++) o++;
    for (ip.v[1:0] = 0; ip.v[1:0] < 2; ip.v[1:0]++) o++;
  end
endmodule
module wrap(output int o);
  ifc i();
  top t(.ip(i), .o(o));
endmodule
