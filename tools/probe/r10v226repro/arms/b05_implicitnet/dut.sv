// v226 b05 — does the new process emission MINT NETS into the def view?
// `implicitNetModule = iface` is raised for this loop; an interface's Nets
// vector is the object §223/§224/§225 all legislate over, so any implicit net
// created here moves THEIR cells.  Legal SV: an undeclared identifier driven
// by a continuous assign gets an implicit net; inside a procedural block it is
// an error, so the probe here is (a) the cont_assign implicit net, which must
// be identical either way, and (b) a reference in a process to a name declared
// only in the modport / only as a genvar.
interface bn_if;
  logic src;
  assign undeclared_a = src;        // implicit net, cont_assign road
  int   k;
  initial begin
    k = 1;
    if (undeclared_a) k = 2;        // read of the implicit net from a process
  end
  always_comb src = undeclared_a;
endinterface

module bn_mod;
  logic src;
  assign undeclared_b = src;
  int   k;
  initial begin
    k = 1;
    if (undeclared_b) k = 2;
  end
endmodule
